import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> markers = [];
  LatLng? userLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    loadMarkers();
    determinePosition();
  }

  // Coordenadas de sitios para comer en Madrid
  final List<Map<String, dynamic>> exampleCoordinates = [
    // Bares
    {'latitude': 40.414497, 'longitude': -3.700367, 'name': 'Salmon Guru', 'type': 'bar', 'rating': 4.5},
    {'latitude': 40.416706, 'longitude': -3.701846, 'name': 'Cervecería La Sureña', 'type': 'bar', 'rating': 4.0},
    {'latitude': 40.426483, 'longitude': -3.702175, 'name': 'La Vía Láctea', 'type': 'bar', 'rating': 4.2},
    {'latitude': 40.426057, 'longitude': -3.703398, 'name': 'Ojalá', 'type': 'bar', 'rating': 4.3},
    {'latitude': 40.425081, 'longitude': -3.700418, 'name': '1862 Dry Bar', 'type': 'bar', 'rating': 4.4},
    {'latitude': 40.422451, 'longitude': -3.708554, 'name': 'Malamadre', 'type': 'bar', 'rating': 4.1},
    {'latitude': 40.424675, 'longitude': -3.703020, 'name': 'Bodega de la Ardosa', 'type': 'bar', 'rating': 4.5},
    {'latitude': 40.468278, 'longitude': -3.688326, 'name': 'Cervecería Santa Bárbara', 'type': 'bar', 'rating': 4.0},
    {'latitude': 40.439626, 'longitude': -3.677036, 'name': 'Macera TallerBar', 'type': 'bar', 'rating': 4.3},
    {'latitude': 40.438760, 'longitude': -3.677160, 'name': 'La Violeta', 'type': 'bar', 'rating': 4.2},
    {'latitude': 40.448139, 'longitude': -3.707365, 'name': 'Sala Maravillas', 'type': 'bar', 'rating': 4.1},
    {'latitude': 40.438415, 'longitude': -3.692226, 'name': 'Picalagartos Sky Bar', 'type': 'bar', 'rating': 4.4},
    {'latitude': 40.444639, 'longitude': -3.690561, 'name': 'El Perro de la Parte de Atrás del Coche', 'type': 'bar', 'rating': 4.3},
    {'latitude': 40.437506, 'longitude': -3.684867, 'name': 'El Junco', 'type': 'bar', 'rating': 4.1},
    {'latitude': 40.448167, 'longitude': -3.693824, 'name': 'Katz Madrid', 'type': 'bar', 'rating': 4.5},
    {'latitude': 40.444490, 'longitude': -3.670436, 'name': 'La Vía Láctea', 'type': 'bar', 'rating': 4.0},
    {'latitude': 40.454272, 'longitude': -3.688442, 'name': 'The Irish Rover', 'type': 'bar', 'rating': 4.2},
    // Cafés
    {'latitude': 40.414371, 'longitude': -3.702550, 'name': 'Café del Art', 'type': 'cafe', 'rating': 4.6},
    {'latitude': 40.426352, 'longitude': -3.702153, 'name': 'Toma Café', 'type': 'cafe', 'rating': 4.4},
    {'latitude': 40.426470, 'longitude': -3.702907, 'name': 'La Bicicleta Café', 'type': 'cafe', 'rating': 4.3},
    {'latitude': 40.425109, 'longitude': -3.712545, 'name': 'Mür Café', 'type': 'cafe', 'rating': 4.5},
    {'latitude': 40.417964, 'longitude': -3.705489, 'name': 'La Mallorquina', 'type': 'cafe', 'rating': 4.2},
    {'latitude': 40.409244, 'longitude': -3.707575, 'name': 'Ruda Café', 'type': 'cafe', 'rating': 4.1},
    {'latitude': 40.443836, 'longitude': -3.703845, 'name': 'Monkee Koffee', 'type': 'cafe', 'rating': 4.4},
    {'latitude': 40.436128, 'longitude': -3.699580, 'name': 'Toma Café', 'type': 'cafe', 'rating': 4.3},
    {'latitude': 40.436356, 'longitude': -3.703353, 'name': 'Lolina Vintage Café', 'type': 'cafe', 'rating': 4.2},
    {'latitude': 40.429726, 'longitude': -3.704944, 'name': 'Café Comercial', 'type': 'cafe', 'rating': 4.6},
    {'latitude': 40.444613, 'longitude': -3.692398, 'name': 'Salon des Fleurs', 'type': 'cafe', 'rating': 4.5},
    {'latitude': 40.446530, 'longitude': -3.692310, 'name': 'Café & Té', 'type': 'cafe', 'rating': 4.1},
    {'latitude': 40.429273, 'longitude': -3.709008, 'name': 'El Dinosaurio Todavía Estaba Allí', 'type': 'cafe', 'rating': 4.2},
    {'latitude': 40.439601, 'longitude': -3.690926, 'name': 'Café Melba', 'type': 'cafe', 'rating': 4.4},
    {'latitude': 40.443501, 'longitude': -3.690989, 'name': 'La Libre', 'type': 'cafe', 'rating': 4.3},
    {'latitude': 40.429187, 'longitude': -3.691725, 'name': 'Boconó', 'type': 'cafe', 'rating': 4.2},
    {'latitude': 40.438709, 'longitude': -3.670764, 'name': 'Miga Bakery', 'type': 'cafe', 'rating': 4.5},
    // Restaurantes
    {'latitude': 40.415325, 'longitude': -3.708683, 'name': 'Sobrino de Botín', 'type': 'restaurant', 'rating': 4.7},
    {'latitude': 40.429209, 'longitude': -3.688675, 'name': 'Ramon Freixa', 'type': 'restaurant', 'rating': 4.6},
    {'latitude': 40.426071, 'longitude': -3.683601, 'name': 'Punto MX', 'type': 'restaurant', 'rating': 4.5},
    {'latitude': 40.447764, 'longitude': -3.689595, 'name': 'Santceloni', 'type': 'restaurant', 'rating': 4.8},
    {'latitude': 40.423174, 'longitude': -3.692473, 'name': 'StreetXO', 'type': 'restaurant', 'rating': 4.4},
    {'latitude': 40.426399, 'longitude': -3.699024, 'name': 'DSTAgE', 'type': 'restaurant', 'rating': 4.7},
    {'latitude': 40.426123, 'longitude': -3.693428, 'name': 'La Vaca y La Huerta', 'type': 'restaurant', 'rating': 4.3},
    {'latitude': 40.438472, 'longitude': -3.690417, 'name': "O'Pazo", 'type': 'restaurant', 'rating': 4.4},
    {'latitude': 40.428850, 'longitude': -3.685636, 'name': 'Goizeko Wellington', 'type': 'restaurant', 'rating': 4.6},
    {'latitude': 40.431234, 'longitude': -3.707123, 'name': 'Yakitoro', 'type': 'restaurant', 'rating': 4.5},
    {'latitude': 40.422268, 'longitude': -3.704846, 'name': 'Casa Lucio', 'type': 'restaurant', 'rating': 4.7},
    {'latitude': 40.440387, 'longitude': -3.688295, 'name': 'Álbora', 'type': 'restaurant', 'rating': 4.4},
    {'latitude': 40.423542, 'longitude': -3.687889, 'name': 'Alabaster', 'type': 'restaurant', 'rating': 4.6},
    {'latitude': 40.424112, 'longitude': -3.688929, 'name': 'Sacha', 'type': 'restaurant', 'rating': 4.5},
    {'latitude': 40.426634, 'longitude': -3.701370, 'name': 'El Club Allard', 'type': 'restaurant', 'rating': 4.7},
    {'latitude': 40.427190, 'longitude': -3.701740, 'name': 'DiverXO', 'type': 'restaurant', 'rating': 4.8},
    {'latitude': 40.426690, 'longitude': -3.699760, 'name': 'Rosi La Loca', 'type': 'restaurant', 'rating': 4.3},
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
            _showPlaceDetails(record['name'], record['type'], record['rating']);
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
  void _showPlaceDetails(String name, String type, double rating) {
    String typeText;
    switch (type) {
      case 'restaurant':
        typeText = 'Restaurante';
        break;
      case 'cafe':
        typeText = 'Café';
        break;
      case 'bar':
        typeText = 'Bar';
        break;
      default:
        typeText = 'Lugar';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Se trata de un: $typeText'),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 5),
                  Text('Valoración: $rating'),
                ],
              ),
            ],
          ),
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
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(40.416775, -3.703790), // Centro inicial en Madrid
        initialZoom: 15,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all,
          enableMultiFingerGestureRace: true,
        ),
        minZoom: 3,
        maxZoom: 18,
      ),
      children: [
        openStreetMapTileLayer,
        MarkerLayer(markers: markers),
        _buildZoomButtons(),
      ],
    );
  }

  Widget _buildZoomButtons() {
    return Positioned(
      right: 20,
      bottom: 20,
      child: Column(
        children: [
          FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              var currentZoom = _mapController.camera.zoom;
              var newZoom = currentZoom + 1;
              _mapController.move(_mapController.camera.center, newZoom);
            },
            heroTag: "zoomIn",
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            child: Icon(Icons.remove),
            onPressed: () {
              var currentZoom = _mapController.camera.zoom;
              var newZoom = currentZoom - 1;
              _mapController.move(_mapController.camera.center, newZoom);
            },
            heroTag: "zoomOut",
          ),
        ],
      ),
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
