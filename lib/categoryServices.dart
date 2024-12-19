import 'package:flutter/material.dart';

// Service model to hold service details
class Service {
  final String providerName;
  final String serviceType;
  final String serviceName;
  final String rangePrice;
  final double rating;
  final String location;
  final String image;

  Service({
    required this.providerName,
    required this.serviceType,
    required this.serviceName,
    required this.rangePrice,
    required this.rating,
    required this.location,
    required this.image,
  });
}

// Service Card Widget to display individual services
class ServiceCard extends StatelessWidget {
  final String providerName;
  final String serviceType;
  final String serviceName;
  final String rangePrice;
  final double rating;
  final String location;
  final String image;

  ServiceCard({
    required this.providerName,
    required this.serviceType,
    required this.serviceName,
    required this.rangePrice,
    required this.rating,
    required this.location,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Service Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),

            // Service Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    providerName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    serviceType,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 5),
                  Text(
                    serviceName,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 5),
                  Text(
                    rangePrice,
                    style: TextStyle(fontSize: 14, color: Colors.green),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.orange),
                      SizedBox(width: 5),
                      Text(
                        rating.toString(),
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryServicesPage extends StatelessWidget {
  final String category;

  CategoryServicesPage({required this.category});

  @override
  Widget build(BuildContext context) {
    // List of services for each category
    final Map<String, List<Service>> servicesByCategory = {
      'Plumbing': [
        Service(
          providerName: 'John\'s Plumbing Co.',
          serviceType: 'Plumbing',
          serviceName: 'Pipe Repair',
          rangePrice: '\$50 - \$200',
          rating: 4.5,
          location: 'New York, NY',
          image: 'images/logo1.png',
        ),
        // More plumbing services here...
      ],
      'Electrical': [
        Service(
          providerName: 'Bright Electricians',
          serviceType: 'Electrical',
          serviceName: 'Wiring Installation',
          rangePrice: '\$100 - \$500',
          rating: 4.0,
          location: 'Los Angeles, CA',
          image: 'images/logo1.png',
        ),
        // More electrical services here...
      ],
      'Air Conditioning': [
        Service(
          providerName: 'Cool Breeze AC Services',
          serviceType: 'Air Conditioning',
          serviceName: 'AC Installation',
          rangePrice: '\$200 - \$800',
          rating: 4.7,
          location: 'Miami, FL',
          image: 'images/logo1.png',
        ),
        // More air conditioning services here...
      ],
      'Cleaning': [
        Service(
          providerName: 'Sparkling Clean',
          serviceType: 'Cleaning',
          serviceName: 'House Cleaning',
          rangePrice: '\$40 - \$150',
          rating: 4.8,
          location: 'San Francisco, CA',
          image: 'images/logo1.png',
        ),
        // More cleaning services here...
      ],
      // Add other categories and services similarly...
    };

    final List<Service> categoryServices = servicesByCategory[category] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('$category Services'),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16.0),
        itemCount: categoryServices.length,
        separatorBuilder: (context, index) => SizedBox(height: 10),
        itemBuilder: (context, index) {
          return ServiceCard(
            providerName: categoryServices[index].providerName,
            serviceType: categoryServices[index].serviceType,
            serviceName: categoryServices[index].serviceName,
            rangePrice: categoryServices[index].rangePrice,
            rating: categoryServices[index].rating,
            location: categoryServices[index].location,
            image: categoryServices[index].image,
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CategoryServicesPage(category: 'Plumbing'), // Example: displaying Plumbing services
  ));
}
