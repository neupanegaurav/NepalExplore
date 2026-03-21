import 'package:latlong2/latlong.dart';
import '../domain/tourist_spot.dart';

final List<TouristSpot> dummyTouristSpots = [
  // Historical Sites (1-15)
  TouristSpot(
    id: '1',
    name: 'Swayambhunath Stupa',
    description:
        'Ancient religious architecture atop a hill in the Kathmandu Valley. often referred to as the Monkey Temple.',
    location: LatLng(27.7149, 85.2903),
    category: SpotCategory.religiousPlaces,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Swayambhunath_Temple-2022.jpg/800px-Swayambhunath_Temple-2022.jpg',
  ),
  TouristSpot(
    id: '2',
    name: 'Kathmandu Durbar Square',
    description:
        'Historic seat of Nepalese royalty, featuring stunning Newari architecture and ancient temples.',
    location: LatLng(27.7042, 85.3060),
    category: SpotCategory.historicalSites,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Kathmandu_Durbar_Square_Pigeon.jpg/800px-Kathmandu_Durbar_Square_Pigeon.jpg',
  ),
  TouristSpot(
    id: '3',
    name: 'Patan Durbar Square',
    description:
        'Renowned for its heritage of fine arts and classical Nepalese architecture.',
    location: LatLng(27.6727, 85.3253),
    category: SpotCategory.historicalSites,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Patan_Durbar_Square_Panorama.jpg/800px-Patan_Durbar_Square_Panorama.jpg',
  ),
  TouristSpot(
    id: '4',
    name: 'Bhaktapur Durbar Square',
    description:
        'The plaza in front of the royal palace of the old Bhaktapur Kingdom.',
    location: LatLng(27.6715, 85.4294),
    category: SpotCategory.historicalSites,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Nyatapola_Temple%2C_Bhaktapur_Durbar_Square.jpg/800px-Nyatapola_Temple%2C_Bhaktapur_Durbar_Square.jpg',
  ),
  TouristSpot(
    id: '5',
    name: 'Lumbini',
    description: 'The birthplace of Siddhartha Gautama, the Lord Buddha.',
    location: LatLng(27.4816, 83.2766),
    category: SpotCategory.historicalSites,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Maya_Devi_Temple_Lumbini.jpg/800px-Maya_Devi_Temple_Lumbini.jpg',
  ),
  TouristSpot(
    id: '6',
    name: 'Gorkha Durbar',
    description:
        'The ancestral palace of the Shah dynasty built in the 16th century.',
    location: LatLng(28.0051, 84.6225),
    category: SpotCategory.historicalSites,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/77/Gorkha_Durbar_Palace.jpg/800px-Gorkha_Durbar_Palace.jpg',
  ),
  TouristSpot(
    id: '7',
    name: 'Nuwakot Palace',
    description: 'Historic seven-story palace built by Prithvi Narayan Shah.',
    location: LatLng(27.9157, 85.1614),
    category: SpotCategory.historicalSites,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Nuwakot_Durbar.jpg/800px-Nuwakot_Durbar.jpg',
  ),
  TouristSpot(
    id: '8',
    name: 'Janaki Mandir',
    description:
        'Hindu temple dedicated to Goddess Sita, stunning Mughal architecture.',
    location: LatLng(26.7303, 85.9264),
    category: SpotCategory.historicalSites,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Janaki_Mandir_Janakpur.jpeg/800px-Janaki_Mandir_Janakpur.jpeg',
  ),
  TouristSpot(
    id: '9',
    name: 'Tansen Durbar',
    description: 'Ancient palace in the hills of Palpa.',
    location: LatLng(27.8681, 83.5658),
    category: SpotCategory.historicalSites,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '10',
    name: 'Changunarayan Temple',
    description: 'The oldest Hindu temple in use in the Kathmandu Valley.',
    location: LatLng(27.7161, 85.4278),
    category: SpotCategory.historicalSites,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '11',
    name: 'Kirtipur Historic City',
    description:
        'Ancient Newar township with rich history and classic streets.',
    location: LatLng(27.6781, 85.2755),
    category: SpotCategory.historicalSites,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '12',
    name: 'Sindhuli Gadhi',
    description: 'Historical fort where Gurkha soldiers defeated the British.',
    location: LatLng(27.2797, 85.9723),
    category: SpotCategory.historicalSites,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '13',
    name: 'Amar Narayan Temple',
    description: 'Historic wooden temple in Tansen.',
    location: LatLng(27.8654, 83.5489),
    category: SpotCategory.historicalSites,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '14',
    name: 'Rani Mahal',
    description:
        'Often called the Taj Mahal of Nepal, situated by the Kali Gandaki river.',
    location: LatLng(27.9407, 83.5857),
    category: SpotCategory.historicalSites,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '15',
    name: 'Panauti Durbar',
    description: 'Ancient square in the preserved Newari town of Panauti.',
    location: LatLng(27.5833, 85.5167),
    category: SpotCategory.historicalSites,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),

  // Religious Places (16-25)
  TouristSpot(
    id: '16',
    name: 'Pashupatinath Temple',
    description:
        'One of the most sacred Hindu temples of Nepal, on the banks of Bagmati.',
    location: LatLng(27.7104, 85.3487),
    category: SpotCategory.religiousPlaces,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Pashupatinath_Temple-2019.jpg/800px-Pashupatinath_Temple-2019.jpg',
  ),
  TouristSpot(
    id: '17',
    name: 'Muktinath Temple',
    description: 'A sacred place for both Hindus and Buddhists in Mustang.',
    location: LatLng(28.8153, 83.8715),
    category: SpotCategory.religiousPlaces,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '18',
    name: 'Manakamana Temple',
    description:
        'Sacred place of the Hindu Goddess Bhagwati, an incarnation of Parvati.',
    location: LatLng(27.9048, 84.5828),
    category: SpotCategory.religiousPlaces,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '19',
    name: 'Gosainkunda Lake',
    description: 'Alpine freshwater oligotrophic lake, sacred in Hinduism.',
    location: LatLng(28.0827, 85.4144),
    category: SpotCategory.religiousPlaces,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '20',
    name: 'Boudhanath Stupa',
    description:
        'One of the largest spherical stupas in Nepal, and a center of Tibetan Buddhism.',
    location: LatLng(27.7215, 85.3620),
    category: SpotCategory.religiousPlaces,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Boudhanath_Stupa_in_Kathmandu.jpg/800px-Boudhanath_Stupa_in_Kathmandu.jpg',
  ),
  TouristSpot(
    id: '21',
    name: 'Pathibhara Devi',
    description: 'Highly revered shrine in eastern Nepal.',
    location: LatLng(27.4287, 87.7788),
    category: SpotCategory.religiousPlaces,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '22',
    name: 'Budhanilkantha',
    description:
        'Large statue of sleeping Lord Vishnu carved from a single floating stone.',
    location: LatLng(27.7770, 85.3639),
    category: SpotCategory.religiousPlaces,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '23',
    name: 'Dakshinkali Temple',
    description:
        'Dedicated to the goddess Kali, located in the south of Kathmandu.',
    location: LatLng(27.6046, 85.2599),
    category: SpotCategory.religiousPlaces,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '24',
    name: 'Devghat Dham',
    description:
        'Holistic center situated at the junction of Seti and Krishna Gandaki rivers.',
    location: LatLng(27.7171, 84.4316),
    category: SpotCategory.religiousPlaces,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '25',
    name: 'Tengboche Monastery',
    description: 'Tibetan Buddhist monastery in the Khumbu valley.',
    location: LatLng(27.8361, 86.7644),
    category: SpotCategory.religiousPlaces,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),

  // Nature Trails (26-40)
  TouristSpot(
    id: '26',
    name: 'Shivapuri Nagarjun National Park',
    description:
        'Protected area offering great nature trails and a quick escape from the city.',
    location: LatLng(27.7979, 85.3888),
    category: SpotCategory.natureTrails,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Shivapuri_National_Park.jpg/800px-Shivapuri_National_Park.jpg',
  ),
  TouristSpot(
    id: '27',
    name: 'Annapurna Base Camp Trek',
    description:
        'Legendary trekking route offering amphitheater views of the Himalayas.',
    location: LatLng(28.5300, 83.8780),
    category: SpotCategory.natureTrails,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '28',
    name: 'Everest Base Camp',
    description: 'The iconic trek to the foot of the worlds highest mountain.',
    location: LatLng(28.0060, 86.8524),
    category: SpotCategory.natureTrails,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '29',
    name: 'Langtang Valley Trek',
    description: 'Beautiful valley known as the valley of glaciers.',
    location: LatLng(28.2167, 85.5667),
    category: SpotCategory.natureTrails,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '30',
    name: 'Chitwan National Park',
    description: 'Dense forests offering elephant safaris and rhino spotting.',
    location: LatLng(27.5341, 84.4525),
    category: SpotCategory.natureTrails,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '31',
    name: 'Bardiya National Park',
    description: 'Pristine conservation area famous for Bengal Tigers.',
    location: LatLng(28.3949, 81.2828),
    category: SpotCategory.natureTrails,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '32',
    name: 'Poon Hill Trek',
    description:
        'Short trek featuring incredible sunrise views over the Annapurna range.',
    location: LatLng(28.4005, 83.6885),
    category: SpotCategory.natureTrails,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '33',
    name: 'Rara Lake',
    description: 'The largest fresh water lake in the Nepalese Himalayas.',
    location: LatLng(29.5311, 82.0784),
    category: SpotCategory.natureTrails,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '34',
    name: 'Phoksundo Lake',
    description:
        'Alpine fresh water oligotrophic lake in Shey Phoksundo National Park.',
    location: LatLng(29.1983, 82.9515),
    category: SpotCategory.natureTrails,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '35',
    name: 'Koshi Tappu Wildlife Reserve',
    description: 'Famous for bird watching and the wild water buffalo.',
    location: LatLng(26.6022, 86.9934),
    category: SpotCategory.natureTrails,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '36',
    name: 'Makalu Barun National Park',
    description:
        'Remote national park with profound elevations and deep gorges.',
    location: LatLng(27.7667, 87.1167),
    category: SpotCategory.natureTrails,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '37',
    name: 'Khaptad National Park',
    description:
        'A hidden gem in the far west offering rolling green hills and peace.',
    location: LatLng(29.3582, 81.1610),
    category: SpotCategory.natureTrails,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '38',
    name: 'Helambu Trek',
    description:
        'Accessible trekking region known for sweet apples and Buddhist culture.',
    location: LatLng(28.0267, 85.5097),
    category: SpotCategory.natureTrails,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '39',
    name: 'Manaslu Circuit',
    description:
        'Geographically spectacular and culturally fascinating mountain trek.',
    location: LatLng(28.5497, 84.5619),
    category: SpotCategory.natureTrails,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '40',
    name: 'Mardi Himal Trek',
    description:
        'A newly opened route offering stunning views of Machhapuchhre.',
    location: LatLng(28.4554, 83.8741),
    category: SpotCategory.natureTrails,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),

  // Viewpoints (41-55)
  TouristSpot(
    id: '41',
    name: 'Nagarkot Viewpoint',
    description:
        'Village renowned for sunrise views of the Himalayas including Mount Everest.',
    location: LatLng(27.7176, 85.5218),
    category: SpotCategory.viewpoints,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '42',
    name: 'Sarangkot',
    description:
        'Famed for panoramic views of Annapurna, Dhaulagiri, and Machhapuchhre.',
    location: LatLng(28.2439, 83.9486),
    category: SpotCategory.viewpoints,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '43',
    name: 'Kala Patthar',
    description: 'Offers the most accessible closeup view of Everest.',
    location: LatLng(27.9959, 86.8285),
    category: SpotCategory.viewpoints,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '44',
    name: 'Chandragiri Hills',
    description:
        'Cable car destination offering sweeping views of Kathmandu Valley.',
    location: LatLng(27.6405, 85.2039),
    category: SpotCategory.viewpoints,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '45',
    name: 'Kakani',
    description:
        'A quiet hill station offering views of the Ganesh Himal range.',
    location: LatLng(27.8049, 85.2530),
    category: SpotCategory.viewpoints,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '46',
    name: 'Bandipur',
    description:
        'Preserved Newari town with stunning views of the Marsyangdi valley architecture.',
    location: LatLng(27.9389, 84.4172),
    category: SpotCategory.viewpoints,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '47',
    name: 'Dhulikhel Viewpoint',
    description:
        'Old Newari town offering excellent panoramic views of the snowy ranges.',
    location: LatLng(27.6253, 85.5222),
    category: SpotCategory.viewpoints,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '48',
    name: 'Phulchowki',
    description:
        'The highest hill in the Kathmandu Valley, great for hiking and bird watching.',
    location: LatLng(27.5701, 85.3995),
    category: SpotCategory.viewpoints,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '49',
    name: 'Gokyo Ri',
    description:
        'A peak offering a panoramic view of Everest and surrounding mountains.',
    location: LatLng(27.9575, 86.6833),
    category: SpotCategory.viewpoints,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '50',
    name: 'World Peace Pagoda Pokhara',
    description:
        'Massive Buddhist stupa on Ananda hill overlooking Phewa Lake.',
    location: LatLng(28.2045, 83.9431),
    category: SpotCategory.viewpoints,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '51',
    name: 'Tsum Valley',
    description:
        'A sacred Himalayan pilgrimage valley with ancient art and culture.',
    location: LatLng(28.5333, 84.9667),
    category: SpotCategory.viewpoints,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '52',
    name: 'Khopra Ridge',
    description: 'Off-the-beaten-path viewpoint facing Mount Dhaulagiri.',
    location: LatLng(28.4900, 83.7225),
    category: SpotCategory.viewpoints,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '53',
    name: 'Ilam Tea Gardens',
    description:
        'Lush green tea estates rolling over the hills of eastern Nepal.',
    location: LatLng(26.9079, 87.9252),
    category: SpotCategory.viewpoints,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '54',
    name: 'Namche Bazaar',
    description: 'The gateway to the high Himalayas and Everest region.',
    location: LatLng(27.8069, 86.7140),
    category: SpotCategory.viewpoints,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '55',
    name: 'Daman View Tower',
    description:
        'Offers the greatest unhindered view of the Himalayas from Dhaulagiri to Everest.',
    location: LatLng(27.6000, 85.0833),
    category: SpotCategory.viewpoints,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),

  // Picnic Areas (56-65)
  TouristSpot(
    id: '56',
    name: 'Godawari Botanical Garden',
    description:
        'Lush gardens at the foot of Phulchowki hill, perfect for family picnics.',
    location: LatLng(27.5935, 85.3854),
    category: SpotCategory.picnicArea,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '57',
    name: 'Tribhuvan Park',
    description:
        'Large municipal park at Thankot, highly popular for weekend picnics.',
    location: LatLng(27.6896, 85.2078),
    category: SpotCategory.picnicArea,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '58',
    name: 'Kakani Picnic Spot',
    description:
        'Scenic picnic areas overlooking the central Himalayan ranges.',
    location: LatLng(27.8105, 85.2590),
    category: SpotCategory.picnicArea,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '59',
    name: 'Taudaha Lake',
    description:
        'Peaceful lake area on the outskirts of Kathmandu, great for relaxing.',
    location: LatLng(27.6433, 85.2819),
    category: SpotCategory.picnicArea,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '60',
    name: 'Surya Chaur',
    description:
        'Beautiful grassy hill north of Kathmandu offering stunning mountain vistas.',
    location: LatLng(27.8286, 85.3400),
    category: SpotCategory.picnicArea,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '61',
    name: 'Bhotechaur Tea Garden',
    description:
        'Known as "Mini Ilam", small tea estate perfect for photos and picnics.',
    location: LatLng(27.8093, 85.5097),
    category: SpotCategory.picnicArea,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '62',
    name: 'Sundarijal',
    description: 'Forest river streams and waterfalls, a classic getaway spot.',
    location: LatLng(27.7667, 85.4167),
    category: SpotCategory.picnicArea,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '63',
    name: 'Panchakanya Park',
    description: 'Lovely green space in Dharan, eastern Nepal.',
    location: LatLng(26.8125, 87.2783),
    category: SpotCategory.picnicArea,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '64',
    name: 'Begnas Lake',
    description: 'Quiet and serene lake in Pokhara, less crowded than Phewa.',
    location: LatLng(28.1692, 84.0933),
    category: SpotCategory.picnicArea,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '65',
    name: 'Chobhar Gorge',
    description:
        'Historical gorge with picnic facilities and Jal Binayak temple nearby.',
    location: LatLng(27.6528, 85.2831),
    category: SpotCategory.picnicArea,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),

  // Cycling / Offroad Spots (66-75)
  TouristSpot(
    id: '66',
    name: 'Shivapuri Cycling Trail',
    description:
        'Challenging uphill mountain biking trails through dense forest.',
    location: LatLng(27.7900, 85.3900),
    category: SpotCategory.cyclingSpots,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '67',
    name: 'Mustang Offroad Route',
    description:
        'World-renowned arid valley trails specifically for 4x4 and adventure bikes.',
    location: LatLng(29.1833, 83.9667),
    category: SpotCategory.offroadRiding,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '68',
    name: 'Changu Narayan MTB Trail',
    description: 'Technical downhill and cross-country flow trails.',
    location: LatLng(27.7121, 85.4208),
    category: SpotCategory.cyclingSpots,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '69',
    name: 'Pathilaya to Hetauda Highway',
    description:
        'A beloved stretching route famous among long-distance road cyclists.',
    location: LatLng(27.0519, 84.8805),
    category: SpotCategory.cyclingSpots,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '70',
    name: 'Manang Valley Dirt Road',
    description: 'Extreme offroading along the Marshyangdi river cliffs.',
    location: LatLng(28.6667, 84.0167),
    category: SpotCategory.offroadRiding,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '71',
    name: 'Lubhu to Lele Trail',
    description: 'Serene village roads perfect for weekend mountain biking.',
    location: LatLng(27.6180, 85.3411),
    category: SpotCategory.cyclingSpots,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '72',
    name: 'Kalinchowk 4x4 Trail',
    description:
        'Steep snow-covered dirt roads making for intense off-road drives in winter.',
    location: LatLng(27.7333, 86.0333),
    category: SpotCategory.offroadRiding,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '73',
    name: 'Pharping to Kulekhani',
    description: 'Long dirt and gravel climbs suitable for endurance cyclists.',
    location: LatLng(27.6000, 85.1667),
    category: SpotCategory.cyclingSpots,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '74',
    name: 'Ramechhap Ridge Ride',
    description: 'Enduro bike trail offering scenic ridges and tough descents.',
    location: LatLng(27.3235, 86.0827),
    category: SpotCategory.offroadRiding,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '75',
    name: 'Hattiban Downhill',
    description:
        'Dedicated downhill mountain biking track with jumps and berms.',
    location: LatLng(27.6167, 85.2500),
    category: SpotCategory.cyclingSpots,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),

  // Mountains & Sceneries (76-85)
  TouristSpot(
    id: '76',
    name: 'Mount Everest (Sagarmatha)',
    description: 'The highest mountain peak in the world.',
    location: LatLng(27.9881, 86.9250),
    category: SpotCategory.mountains,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '77',
    name: 'Machhapuchhre (Fishtail)',
    description: 'Iconic virgin peak dominating the Pokhara skyline.',
    location: LatLng(28.4950, 83.9486),
    category: SpotCategory.mountains,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '78',
    name: 'Annapurna Massif',
    description:
        'Spectacular mountain range featuring several peaks over 7,000m.',
    location: LatLng(28.5961, 83.8203),
    category: SpotCategory.mountains,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '79',
    name: 'Ama Dablam',
    description:
        'Considered one of the most beautiful mountains in the Himalayas.',
    location: LatLng(27.8611, 86.8611),
    category: SpotCategory.mountains,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '80',
    name: 'Dhaulagiri',
    description: 'The seventh highest mountain in the world.',
    location: LatLng(28.6975, 83.4872),
    category: SpotCategory.mountains,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '81',
    name: 'Upper Mustang Scenery',
    description:
        'Desert-like arid landscapes contrasting with white snow peaks.',
    location: LatLng(29.1833, 83.9667),
    category: SpotCategory.sceneries,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '82',
    name: 'Khaptad Scenery',
    description:
        'Meadows and rolling green hills providing tranquil scenic beauty.',
    location: LatLng(29.3582, 81.1610),
    category: SpotCategory.sceneries,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '83',
    name: 'Gokyo Lakes',
    description:
        'World\'s highest freshwater lake system with turquoise waters.',
    location: LatLng(27.9533, 86.6917),
    category: SpotCategory.sceneries,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '84',
    name: 'Sankhuwasabha Cloud Forest',
    description: 'Dense rhododendron forests covered in mystical fog.',
    location: LatLng(27.5000, 87.2500),
    category: SpotCategory.sceneries,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '85',
    name: 'Manaslu Base Camp',
    description: 'Awe-inspiring views beneath the eighth highest mountain.',
    location: LatLng(28.5500, 84.5667),
    category: SpotCategory.sceneries,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),

  // Tourist Agents / Info Centers (86-100)
  TouristSpot(
    id: '86',
    name: 'Thamel Tourist Hub',
    description:
        'Kathmandu\'s main spot for booking treks, tours, and expeditions.',
    location: LatLng(27.7153, 85.3123),
    category: SpotCategory.touristAgents,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '87',
    name: 'Pokhara Lakeside Info Center',
    description: 'Central hub for Annapurna conservation permits and guides.',
    location: LatLng(28.2100, 83.9575),
    category: SpotCategory.touristAgents,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '88',
    name: 'NTB Tourist Board',
    description: 'Official Nepal Tourism Board office in Kathmandu.',
    location: LatLng(27.7011, 85.3175),
    category: SpotCategory.touristAgents,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '89',
    name: 'Lukla Guide Bureau',
    description:
        'For hiring guides and porters right after landing in the Everest region.',
    location: LatLng(27.6861, 86.7289),
    category: SpotCategory.touristAgents,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '90',
    name: 'Chitwan Safari Agencies',
    description: 'Sauraha is packed with agencies booking jungle safaris.',
    location: LatLng(27.5819, 84.4819),
    category: SpotCategory.touristAgents,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '91',
    name: 'Mustang Permit Office',
    description:
        'Required office for crossing into the restricted Upper Mustang area.',
    location: LatLng(28.7833, 83.7167),
    category: SpotCategory.touristAgents,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '92',
    name: 'Bandipur Tourism Council',
    description: 'Helpful local center for arranging homestays and tours.',
    location: LatLng(27.9389, 84.4172),
    category: SpotCategory.touristAgents,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '93',
    name: 'Lumbini Development Trust',
    description: 'Provides maps and guides for the holy birthplace.',
    location: LatLng(27.4816, 83.2766),
    category: SpotCategory.touristAgents,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '94',
    name: 'Namche Visitor Center',
    description: 'Sagarmatha National Park museum and information desk.',
    location: LatLng(27.8069, 86.7140),
    category: SpotCategory.touristAgents,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '95',
    name: 'Tansen Tourist Office',
    description: 'Local municipality guide booking setup in Palpa.',
    location: LatLng(27.8681, 83.5658),
    category: SpotCategory.touristAgents,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '96',
    name: 'Ilam Tourist Kiosk',
    description: 'Information desk for navigating the tea estates.',
    location: LatLng(26.9079, 87.9252),
    category: SpotCategory.touristAgents,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '97',
    name: 'Bardia National Park Info',
    description: 'Headquarters for securing tiger tracking guides.',
    location: LatLng(28.3949, 81.2828),
    category: SpotCategory.touristAgents,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '98',
    name: 'Langtang Park Checkpoint',
    description: 'Must-stop agency checkpoint at Dhunche for valley trekkers.',
    location: LatLng(28.1064, 85.2975),
    category: SpotCategory.touristAgents,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '99',
    name: 'Gorkha Museum Guides',
    description: 'For historical tours regarding the unification of Nepal.',
    location: LatLng(28.0051, 84.6225),
    category: SpotCategory.touristAgents,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),
  TouristSpot(
    id: '100',
    name: 'Janakpur Pilgrimage Center',
    description:
        'Arranges guides for exploring the various religious ponds and temples.',
    location: LatLng(26.7303, 85.9264),
    category: SpotCategory.touristAgents,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
  ),

  // New Featured Categories
  TouristSpot(
    id: '101',
    name: 'Yak & Yeti Hotel',
    description: 'Luxury hotel in the heart of Kathmandu.',
    location: LatLng(27.7126, 85.3187),
    category: SpotCategory.hotels,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
    priceRange: '\$\$\$',
    contactPhone: '+977-1-4248999',
    isFeatured: true,
    promotionalMessage: 'Exclusive 20% off for Explore Nepal users!',
  ),
  TouristSpot(
    id: '102',
    name: 'Nepal Airlines Ticketing',
    description: 'Official flight ticketing office.',
    location: LatLng(27.7001, 85.3121),
    category: SpotCategory.tickets,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
    priceRange: '\$\$-\$\$\$',
    contactPhone: '+977-1-4220757',
    isFeatured: true,
    promotionalMessage: 'Book scenic mountain flights directly with us.',
  ),
  TouristSpot(
    id: '103',
    name: 'Himalayan Guides Team',
    description: 'Certified mountain guides for your trek.',
    location: LatLng(27.7153, 85.3102),
    category: SpotCategory.guides,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
    priceRange: '\$\$',
    contactPhone: '+977-9841234567',
    isFeatured: false,
    promotionalMessage: 'Safe and guided tours to EBC and Annapurna.',
  ),
  TouristSpot(
    id: '104',
    name: 'Thamel House Restaurant',
    description: 'Authentic Nepali dining experience.',
    location: LatLng(27.7171, 85.3105),
    category: SpotCategory.dining,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/ec/Himalaya_from_Nagarkot.jpg',
    priceRange: '\$\$',
    contactPhone: '+977-1-4410388',
    isFeatured: true,
    promotionalMessage:
        'Experience traditional Nepali thali with live cultural dance!',
  ),
];
