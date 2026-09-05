"""Split the supplied Sri Lanka terrain GLB into nine coloured province meshes."""

from pathlib import Path
import sys

import numpy as np
from shapely.geometry import Polygon
import trimesh


PROVINCES = {
    "Northern": (0xF03A3E, [(0.36,.015),(.43,0),(.50,.018),(.57,.010),(.62,.038),(.68,.064),(.72,.105),(.75,.155),(.70,.205),(.62,.232),(.53,.255),(.43,.238),(.36,.257),(.29,.225),(.27,.175),(.22,.145),(.25,.105),(.31,.085)]),
    "North Western": (0x50DD54, [(.29,.225),(.36,.257),(.43,.238),(.53,.255),(.57,.330),(.53,.405),(.48,.485),(.39,.520),(.31,.555),(.22,.535),(.17,.485),(.145,.425),(.16,.355),(.18,.300),(.23,.265)]),
    "North Central": (0xF0BB37, [(.53,.255),(.62,.232),(.70,.205),(.75,.225),(.78,.285),(.76,.345),(.80,.405),(.74,.455),(.68,.475),(.62,.455),(.56,.475),(.48,.485),(.53,.405),(.57,.330)]),
    "Eastern": (0xF47C32, [(.70,.205),(.75,.185),(.80,.205),(.82,.255),(.86,.295),(.88,.355),(.92,.410),(.925,.475),(.91,.535),(.93,.600),(.91,.670),(.87,.735),(.82,.780),(.76,.760),(.72,.700),(.70,.630),(.67,.565),(.68,.475),(.74,.455),(.80,.405),(.76,.345),(.78,.285),(.75,.225)]),
    "Central": (0x5FC07C, [(.48,.485),(.56,.475),(.62,.455),(.68,.475),(.67,.565),(.70,.630),(.65,.680),(.58,.705),(.50,.690),(.44,.650),(.39,.585),(.39,.520)]),
    "Western": (0x43D2C3, [(.145,.425),(.17,.485),(.22,.535),(.31,.555),(.39,.520),(.39,.585),(.37,.650),(.34,.710),(.37,.775),(.32,.825),(.24,.815),(.20,.770),(.17,.700),(.15,.625),(.13,.545)]),
    "Sabaragamuwa": (0x438ED8, [(.39,.585),(.44,.650),(.50,.690),(.58,.705),(.57,.770),(.53,.825),(.46,.850),(.37,.835),(.32,.825),(.37,.775),(.34,.710),(.37,.650)]),
    "Uva": (0x4167D9, [(.58,.705),(.65,.680),(.70,.630),(.72,.700),(.76,.760),(.82,.780),(.79,.835),(.72,.865),(.64,.850),(.57,.770)]),
    "Southern": (0x6550D7, [(.24,.815),(.32,.825),(.37,.835),(.46,.850),(.53,.825),(.57,.770),(.64,.850),(.72,.865),(.79,.835),(.77,.885),(.72,.925),(.65,.955),(.57,.982),(.48,1),(.39,.988),(.31,.960),(.25,.920),(.21,.870)]),
}


def height_on_triangle(x, z, triangle):
    a, b, c = triangle
    denominator = (b[2] - c[2]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[2] - c[2])
    if abs(denominator) < 1e-12:
        return float((a[1] + b[1] + c[1]) / 3)
    wa = ((b[2] - c[2]) * (x - c[0]) + (c[0] - b[0]) * (z - c[2])) / denominator
    wb = ((c[2] - a[2]) * (x - c[0]) + (a[0] - c[0]) * (z - c[2])) / denominator
    return float(wa * a[1] + wb * b[1] + (1 - wa - wb) * c[1])


def fan_triangulate(coords):
    # Intersections of two triangles/polygons are convex enough for a fan.
    return [(coords[0], coords[i], coords[i + 1]) for i in range(1, len(coords) - 1)]


def main(source, destination):
    scene = trimesh.load(source, force="scene")
    terrain = next(mesh for name, mesh in scene.geometry.items() if name.lower() != "plane")
    xmin, _, zmin = terrain.bounds[0]
    xmax, _, zmax = terrain.bounds[1]

    result = trimesh.Scene()
    for name, (rgb, normalized) in PROVINCES.items():
        region = Polygon([(xmin + x * (xmax - xmin), zmax - y * (zmax - zmin)) for x, y in normalized])
        vertices, faces = [], []
        for face in terrain.faces:
            source_triangle = terrain.vertices[face]
            footprint = Polygon([(v[0], v[2]) for v in source_triangle])
            clipped = footprint.intersection(region)
            polygons = [clipped] if clipped.geom_type == "Polygon" else list(getattr(clipped, "geoms", []))
            for polygon in polygons:
                coords = list(polygon.exterior.coords)[:-1]
                if len(coords) < 3 or polygon.area < 1e-10:
                    continue
                for triangle in fan_triangulate(coords):
                    start = len(vertices)
                    vertices.extend((x, height_on_triangle(x, z, source_triangle) + .003, z) for x, z in triangle)
                    faces.append((start, start + 1, start + 2))

        color = [rgb >> 16, (rgb >> 8) & 255, rgb & 255, 255]
        mesh = trimesh.Trimesh(vertices=np.asarray(vertices), faces=np.asarray(faces), process=False)
        mesh.visual = trimesh.visual.ColorVisuals(
            mesh=mesh, vertex_colors=np.tile(color, (len(vertices), 1))
        )
        result.add_geometry(mesh, node_name=name, geom_name=name)

    destination.parent.mkdir(parents=True, exist_ok=True)
    result.export(destination)
    print(f"Exported {len(result.geometry)} province meshes to {destination}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit("usage: build_province_glb.py source.glb destination.glb")
    main(Path(sys.argv[1]), Path(sys.argv[2]))
