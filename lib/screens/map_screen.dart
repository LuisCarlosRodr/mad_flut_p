import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
// Asegúrate de importar tu helper de base de datos

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> markers = [];
  LatLng? userLocation;

  @override
  void initState() {
    super.initState();
    loadMarkers();
    determinePosition();
  }

  // Coordenadas de sitios para comer en Madrid
  final List<Map<String, dynamic>> exampleCoordinates = [
    // Bares

    {'latitude': 40.414497, 'longitude': -3.700367, 'name': 'Salmon Guru', 'type': 'bar'},
    {'latitude': 40.416706, 'longitude': -3.701846, 'name': 'Cervecería La Sureña', 'type': 'bar'},
    {'latitude': 40.426483, 'longitude': -3.702175, 'name': 'La Vía Láctea', 'type': 'bar'},
    {'latitude': 40.426057, 'longitude': -3.703398, 'name': 'Ojalá', 'type': 'bar'},
    {'latitude': 40.425081, 'longitude': -3.700418, 'name': '1862 Dry Bar', 'type': 'bar'},
    {'latitude': 40.422451, 'longitude': -3.708554, 'name': 'Malamadre', 'type': 'bar'},
    {'latitude': 40.424675, 'longitude': -3.703020, 'name': 'Bodega de la Ardosa', 'type': 'bar'},
    {'latitude': 40.468278, 'longitude': -3.688326, 'name': 'Cervecería Santa Bárbara', 'type': 'bar'},
    {'latitude': 40.439626, 'longitude': -3.677036, 'name': 'Macera TallerBar', 'type': 'bar'},
    {'latitude': 40.438760, 'longitude': -3.677160, 'name': 'La Violeta', 'type': 'bar'},
    {'latitude': 40.448139, 'longitude': -3.707365, 'name': 'Sala Maravillas', 'type': 'bar'},
    {'latitude': 40.438415, 'longitude': -3.692226, 'name': 'Picalagartos Sky Bar', 'type': 'bar'},
    {'latitude': 40.444639, 'longitude': -3.690561, 'name': 'El Perro de la Parte de Atrás del Coche', 'type': 'bar'},
    {'latitude': 40.437506, 'longitude': -3.684867, 'name': 'El Junco', 'type': 'bar'},
    {'latitude': 40.448167, 'longitude': -3.693824, 'name': 'Katz Madrid', 'type': 'bar'},
    {'latitude': 40.444490, 'longitude': -3.670436, 'name': 'La Vía Láctea', 'type': 'bar'},
    {'latitude': 40.454272, 'longitude': -3.688442, 'name': 'The Irish Rover', 'type': 'bar'},

    // Cafés
    {'latitude': 40.414371, 'longitude': -3.702550, 'name': 'Café del Art', 'type': 'cafe'},
    {'latitude': 40.426352, 'longitude': -3.702153, 'name': 'Toma Café', 'type': 'cafe'},
    {'latitude': 40.426470, 'longitude': -3.702907, 'name': 'La Bicicleta Café', 'type': 'cafe'},
    {'latitude': 40.425109, 'longitude': -3.712545, 'name': 'Mür Café', 'type': 'cafe'},
    {'latitude': 40.417964, 'longitude': -3.705489, 'name': 'La Mallorquina', 'type': 'cafe'},
    {'latitude': 40.409244, 'longitude': -3.707575, 'name': 'Ruda Café', 'type': 'cafe'},
    {'latitude': 40.443836, 'longitude': -3.703845, 'name': 'Monkee Koffee', 'type': 'cafe'},
    {'latitude': 40.436128, 'longitude': -3.699580, 'name': 'Toma Café', 'type': 'cafe'},
    {'latitude': 40.436356, 'longitude': -3.703353, 'name': 'Lolina Vintage Café', 'type': 'cafe'},
    {'latitude': 40.429726, 'longitude': -3.704944, 'name': 'Café Comercial', 'type': 'cafe'},
    {'latitude': 40.444613, 'longitude': -3.692398, 'name': 'Salon des Fleurs', 'type': 'cafe'},
    {'latitude': 40.446530, 'longitude': -3.692310, 'name': 'Café & Té', 'type': 'cafe'},
    {'latitude': 40.429273, 'longitude': -3.709008, 'name': 'El Dinosaurio Todavía Estaba Allí', 'type': 'cafe'},
    {'latitude': 40.439601, 'longitude': -3.690926, 'name': 'Café Melba', 'type': 'cafe'},
    {'latitude': 40.443501, 'longitude': -3.690989, 'name': 'La Libre', 'type': 'cafe'},
    {'latitude': 40.429187, 'longitude': -3.691725, 'name': 'Boconó', 'type': 'cafe'},
    {'latitude': 40.438709, 'longitude': -3.670764, 'name': 'Miga Bakery', 'type': 'cafe'},
    // Restaurantes

    {'latitude': 40.415325, 'longitude': -3.708683, 'name': 'Sobrino de Botín', 'type': 'restaurant'},
    {'latitude': 40.429209, 'longitude': -3.688675, 'name': 'Ramon Freixa', 'type': 'restaurant'},
    {'latitude': 40.426071, 'longitude': -3.683601, 'name': 'Punto MX', 'type': 'restaurant'},
    {'latitude': 40.447764, 'longitude': -3.689595, 'name': 'Santceloni', 'type': 'restaurant'},
    {'latitude': 40.423174, 'longitude': -3.692473, 'name': 'StreetXO', 'type': 'restaurant'},
    {'latitude': 40.426399, 'longitude': -3.699024, 'name': 'DSTAgE', 'type': 'restaurant'},
    {'latitude': 40.426123, 'longitude': -3.693428, 'name': 'La Vaca y La Huerta', 'type': 'restaurant'},
    {'latitude': 40.438472, 'longitude': -3.690417, 'name': "O'Pazo", 'type': 'restaurant'},
    {'latitude': 40.428850, 'longitude': -3.685636, 'name': 'Goizeko Wellington', 'type': 'restaurant'},
    {'latitude': 40.431234, 'longitude': -3.692222, 'name': 'Kabuki', 'type': 'restaurant'},
    {'latitude': 40.443663, 'longitude': -3.689124, 'name': "Alfredo's Barbacoa", 'type': 'restaurant'},
    {'latitude': 40.460637, 'longitude': -3.686112, 'name': 'La Vaca y La Huerta', 'type': 'restaurant'},
    {'latitude': 40.440486, 'longitude': -3.681780, 'name': 'Taberna del Alabardero', 'type': 'restaurant'},
    {'latitude': 40.434830, 'longitude': -3.687614, 'name': 'El Olivar', 'type': 'restaurant'},
    {'latitude': 40.469392, 'longitude': -3.683446, 'name': 'La Máquina', 'type': 'restaurant'},
    {'latitude': 40.446423, 'longitude': -3.670470, 'name': 'Punto MX', 'type': 'restaurant'},
    {'latitude': 40.441268, 'longitude': -3.678603, 'name': "A'Barra", 'type': 'restaurant'},
  ];

  // Cargar coordenadas de sitios para comer
  Future<void> loadMarkers() async {
    List<Marker> loadedMarkers = exampleCoordinates.map((record) {
      Color markerColor;
      switch (record['type']) {
        case 'restaurant':
          markerColor = Colors.red;
          break;
        case 'cafe':
          markerColor = Colors.green;
          break;
        case 'bar':
          markerColor = Colors.blue;
          break;
        default:
          markerColor = Colors.yellow;
      }
      return Marker(
        point: LatLng(record['latitude'], record['longitude']),
        width: 80,
        height: 80,
        child: IconButton(
          icon: Icon(
            Icons.location_pin,
            size: 60,
            color: markerColor,
          ),
          onPressed: () {
            _showPlaceDetails(record['name'], record['type']);
          },
        ),
      );
    }).toList();
    setState(() {
      markers = loadedMarkers;
    });
  }

  // Determinar la posición del usuario
  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('El servicio de ubicación está deshabilitado.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación están denegados');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Los permisos de ubicación están permanentemente denegados, no podemos solicitar permisos.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
      markers.add(
        Marker(
          point: userLocation!,
          width: 80,
          height: 80,
          child: const Icon(
            Icons.person_pin_circle,
            size: 60,
            color: Colors.blueAccent,
          ),
        ),
      );
    });
  }

  // Mostrar detalles del lugar
  void _showPlaceDetails(String name, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
          actions: <Widget>[
            TextButton(
              child: const Text("Cerrar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: Stack(
        children: [
          content(),
          Positioned(
            bottom: 10,
            left: 10,
            child: legend(),
          ),
        ],
      ),
    );
  }

  Widget content() {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(40.416775, -3.703790), // Centro inicial en Madrid
        initialZoom: 15,
        interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
      ),
      children: [
        openStreetMapTileLayer,
        MarkerLayer(markers: markers), // Marcadores cargados
      ],
    );
  }

  Widget legend() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white.withOpacity(0.8),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Leyenda:', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Icon(Icons.location_pin, color: Colors.red),
              SizedBox(width: 4),
              Text('Restaurante'),
            ],
          ),
          Row(
            children: [
              Icon(Icons.location_pin, color: Colors.green),
              SizedBox(width: 4),
              Text('Café'),
            ],
          ),
          Row(
            children: [
              Icon(Icons.location_pin, color: Colors.blue),
              SizedBox(width: 4),
              Text('Bar'),
            ],
          ),
          Row(
            children: [
              Icon(Icons.person_pin_circle, color: Colors.blueAccent),
              SizedBox(width: 4),
              Text('Tú estás aquí'),
            ],
          ),
        ],
      ),
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
);
