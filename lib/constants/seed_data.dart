import '../models/home_item.dart';

/// Seeded home screen tiles
final List<HomeItem> seededHome = const [
  HomeItem('yes / no', HomeItemType.category),
  HomeItem('needs', HomeItemType.category),
  HomeItem('feelings', HomeItemType.category),
  HomeItem('food', HomeItemType.category),
  HomeItem('places', HomeItemType.category),
  HomeItem('people', HomeItemType.category),
  HomeItem('help', HomeItemType.quick),
  HomeItem('stop', HomeItemType.quick),
  HomeItem('go', HomeItemType.quick),
  HomeItem('toilet', HomeItemType.quick),
  HomeItem('drink', HomeItemType.quick),
  HomeItem('eat', HomeItemType.quick),
  HomeItem('sleep', HomeItemType.quick),
  HomeItem('pain', HomeItemType.quick),
];

/// Seeded categories with flat word lists
final Map<String, List<String>> seededFlat = {
  'needs': [
    'I need help',
    'I need the toilet',
    'I need a drink',
    'I need to eat',
    'I need to rest',
    'I need my medication',
    'I feel unwell',
    'I am in pain',
    'I need to go outside',
    'I need to be alone',
    'I need assistance to move'
  ],
  'feelings': [
    'Happy',
    'Sad',
    'Angry',
    'Tired',
    'Excited',
    'Scared',
    'Worried',
    'Calm',
    'Confused',
    'Bored',
    'Stressed',
    'Lonely',
    'Uncomfortable',
    'Dizzy',
    'Sick'
  ],
};

/// Seeded categories with nested subcategories
final Map<String, Map<String, List<String>>> seededNested = {
  'food': {
    'meals': [
      'Breakfast',
      'Lunch',
      'Dinner',
      'Snack',
      'I am hungry',
      'More please',
      'No more'
    ],
    'drinks': [
      'Water',
      'Juice',
      'Milk',
      'Tea',
      'Coffee',
      'Hot',
      'Cold',
      'I am thirsty'
    ],
    'items': [
      'Apple',
      'Banana',
      'Bread',
      'Rice',
      'Chicken',
      'Fish',
      'Soup',
      'Yoghurt',
      'Vegetables',
      'Fruit',
      'Chips',
      'I do not like this'
    ]
  },
  'places': {
    'home areas': [
      'Home',
      'Bedroom',
      'Bathroom',
      'Toilet',
      'Kitchen',
      'Dining room',
      'Garden',
      'Outside'
    ],
    'medical': ['Clinic', 'Hospital', 'Pharmacy'],
    'community': ['Shop', 'School', 'Work', 'Community centre', 'Car']
  },
  'people': {
    'family & friends': ['Mum', 'Dad', 'Family', 'Friend', 'Neighbour'],
    'staff & professionals': [
      'Carer',
      'Nurse',
      'Doctor',
      'Physio',
      'Therapist',
      'Support worker',
      'Teacher',
      'Manager'
    ]
  },
  'i want': {
    'care': [
      'I want to go to the toilet',
      'I want a drink',
      'I want to eat',
      'I want to rest',
      'I want to sleep',
      'I want my medication',
      'I want pain relief'
    ],
    'activity': [
      'I want to go outside',
      'I want to sit',
      'I want to stand',
      'I want a different activity',
      'I want music',
      'I want TV'
    ],
    'social': [
      'I want to be alone',
      'I want company',
      'I want to call someone'
    ],
    'control': ['I want to stop', 'I want help', 'I want to go']
  },
};