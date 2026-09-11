import 'package:flutter/foundation.dart';

@immutable
class Question {
  const Question({
    required this.id,
    required this.title,
    required this.body,
    required this.location,
    required this.category,
    required this.timeAgo,
    required this.author,
    required this.authorInitials,
    required this.votes,
    required this.answers,
    required this.isVerified,
  });

  final String id;
  final String title;
  final String body;
  final String location;
  final String category;
  final String timeAgo;
  final String author;
  final String authorInitials;
  final int votes;
  final List<QuestionAnswer> answers;
  final bool isVerified;

  Question copyWith({List<QuestionAnswer>? answers}) => Question(
    id: id,
    title: title,
    body: body,
    location: location,
    category: category,
    timeAgo: timeAgo,
    author: author,
    authorInitials: authorInitials,
    votes: votes,
    answers: answers ?? this.answers,
    isVerified: isVerified,
  );
}

@immutable
class QuestionAnswer {
  const QuestionAnswer({
    this.id = '',
    required this.author,
    required this.authorInitials,
    required this.role,
    required this.timeAgo,
    required this.body,
    required this.votes,
    this.isAccepted = false,
    this.isVerified = false,
    this.replies = const [],
  });

  final String id;
  final String author;
  final String authorInitials;
  final String role;
  final String timeAgo;
  final String body;
  final int votes;
  final bool isAccepted;
  final bool isVerified;
  final List<QuestionAnswer> replies;

  QuestionAnswer copyWith({String? id, List<QuestionAnswer>? replies}) =>
      QuestionAnswer(
        id: id ?? this.id,
        author: author,
        authorInitials: authorInitials,
        role: role,
        timeAgo: timeAgo,
        body: body,
        votes: votes,
        isAccepted: isAccepted,
        isVerified: isVerified,
        replies: replies ?? this.replies,
      );
}

const sampleQuestions = <Question>[
  Question(
    id: 'stupa-walking',
    title: 'What is the correct way to walk around a stupa at Polonnaruwa?',
    body:
        'A monk at Rankoth Vehera gently corrected me last week and I did not want to interrupt him to ask why. Is the clockwise direction a rule, a custom, or something else entirely?',
    location: 'Polonnaruwa',
    category: 'Rituals & Etiquette',
    timeAgo: '4h ago',
    author: 'Amaya Perera',
    authorInitials: 'AP',
    votes: 214,
    isVerified: true,
    answers: [
      QuestionAnswer(
        id: 'stupa-answer-sumedha',
        author: 'Ven. Sumedha',
        authorInitials: 'VS',
        role: 'Heritage keeper',
        timeAgo: '3h ago',
        votes: 168,
        isAccepted: true,
        isVerified: true,
        body:
            'Clockwise circumambulation is called padakkhina. You keep your right shoulder toward the relic as a sign of respect — the right side has long been the honoured side in South Asian custom. It is not enforced, but almost every devotee follows it, so walking against the flow also creates a small traffic jam.',
        replies: [
          QuestionAnswer(
            id: 'stupa-reply-dinuka',
            author: 'Dinuka R.',
            authorInitials: 'DR',
            role: '',
            timeAgo: '2h ago',
            votes: 62,
            body:
                'Adding to this: at Rankoth Vehera the paved path itself was laid out for that direction, so the worn stones tell you where people have walked for eight centuries.',
            replies: [
              QuestionAnswer(
                id: 'stupa-reply-amaya',
                author: 'Amaya Perera',
                authorInitials: 'AP',
                role: 'Local guide',
                timeAgo: '1h ago',
                votes: 18,
                body:
                    'That detail about the worn stones is lovely — I will look for it the next time I guide someone around the site.',
              ),
            ],
          ),
        ],
      ),
      QuestionAnswer(
        author: 'Malini Fernando',
        authorInitials: 'MF',
        role: 'Local contributor',
        timeAgo: '2h ago',
        votes: 31,
        body:
            'It is also considerate to remove hats and keep voices low. At Rankoth Vehera, the stone path naturally guides visitors in the clockwise direction.',
      ),
      QuestionAnswer(
        author: 'Kasun Jayasinghe',
        authorInitials: 'KJ',
        role: 'Heritage enthusiast',
        timeAgo: '1h ago',
        votes: 12,
        body:
            'If a ceremony is taking place, wait at the edge of the path until the group has passed before joining the circuit.',
      ),
    ],
  ),
  Question(
    id: 'gal-vihara-direction',
    title: 'Why do the Gal Vihara Buddha statues face the direction they do?',
    body:
        'The reclining figure and the standing figure seem deliberately oriented. Is there a scriptural reason, or was it dictated by the rock face the sculptors were given?',
    location: 'Gal Vihara',
    category: 'Architecture',
    timeAgo: '9h ago',
    author: 'Mihiri N.',
    authorInitials: 'MN',
    votes: 137,
    isVerified: true,
    answers: [
      QuestionAnswer(
        author: 'Dr. Senaka Silva',
        authorInitials: 'SS',
        role: 'Archaeology lecturer',
        timeAgo: '7h ago',
        votes: 54,
        isAccepted: true,
        body:
            'The granite outcrop strongly shaped the arrangement. The artists used the long natural face of the rock while also creating a procession-like visual sequence for worshippers approaching the shrine.',
      ),
      QuestionAnswer(
        author: 'Nadeesha I.',
        authorInitials: 'NI',
        role: 'Polonnaruwa resident',
        timeAgo: '5h ago',
        votes: 18,
        body:
            'Morning light also reveals the carving beautifully, especially the subtle folds around the reclining figure.',
      ),
    ],
  ),
  Question(
    id: 'photo-sinhala',
    title: 'How do I say “may I take a photograph?” respectfully in Sinhala?',
    body:
        'I keep gesturing at my camera and feeling rude about it. I would love a short phrase, along with the correct pronunciation, before visiting village workshops.',
    location: 'Anuradhapura',
    category: 'Language',
    timeAgo: '1d ago',
    author: 'Lucia Gomez',
    authorInitials: 'LG',
    votes: 89,
    isVerified: false,
    answers: [
      QuestionAnswer(
        author: 'Dinithi Abey',
        authorInitials: 'DA',
        role: 'Sinhala teacher',
        timeAgo: '20h ago',
        votes: 42,
        body:
            'You can ask “Mama photo ekak gannada?” with a friendly tone. Pointing gently to the camera helps, and always wait for a clear yes before taking the photo.',
      ),
    ],
  ),
  Question(
    id: 'kovil-clothing',
    title: 'What should visitors wear when entering a Hindu kovil?',
    body:
        'Are the expectations different from visiting a Buddhist temple, especially for footwear and covering shoulders?',
    location: 'Jaffna',
    category: 'Rituals & Etiquette',
    timeAgo: '1d ago',
    author: 'Ravi Thomas',
    authorInitials: 'RT',
    votes: 76,
    isVerified: true,
    answers: [
      QuestionAnswer(
        author: 'Shalini Kandasamy',
        authorInitials: 'SK',
        role: 'Community member',
        timeAgo: '18h ago',
        votes: 36,
        isAccepted: true,
        body:
            'Choose modest clothing that covers shoulders and knees, and leave footwear at the entrance. Some temples have additional customs, so check signs or ask an attendant.',
      ),
    ],
  ),
  Question(
    id: 'moonstone-symbols',
    title:
        'What do the animals carved into an Anuradhapura moonstone represent?',
    body:
        'I noticed that moonstones from different periods do not always include the same animals. What changed, and why?',
    location: 'Anuradhapura',
    category: 'History',
    timeAgo: '2d ago',
    author: 'Sajith D.',
    authorInitials: 'SD',
    votes: 64,
    isVerified: false,
    answers: [],
  ),
  Question(
    id: 'mask-colours',
    title: 'Do the colours on Ambalangoda masks have fixed meanings?',
    body:
        'Several workshops use similar red, green, and yellow palettes. Are these traditional symbols or simply the paints that were historically available?',
    location: 'Ambalangoda',
    category: 'Crafts',
    timeAgo: '3d ago',
    author: 'Noah Williams',
    authorInitials: 'NW',
    votes: 51,
    isVerified: false,
    answers: [],
  ),
];
