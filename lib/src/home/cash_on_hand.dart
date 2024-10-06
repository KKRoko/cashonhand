import 'package:flutter/material.dart';
import 'calendar_page.dart';

class CashOnHandPage extends StatelessWidget {
  static const routeName = '/cashOnHand';

  const CashOnHandPage({super.key}); // Route name for navigation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash On Hand'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Optional padding around the content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Makes tiles stretch to full width
          children: [
            _buildTile('End of Day'),
            _buildTile('End of Week'),
            _buildTile('End of Month'),
            _buildTile('End of Half Year'),
            _buildTile('End of Year'),
          ],
        ),
      ),
      // Bottom navigation with two icons
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Adds a notch for the FAB
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // Padding for the icons
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Icons on both sides
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  // Navigate to the add entry page (replace with your actual page)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddEntryPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () {
                  // Navigate to the calendar page (replace with your actual page)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CalendarPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      // Optional FloatingActionButton for add entry
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the add entry page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEntryPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Places FAB in the center
    );
  }

  // Helper function to build each tile
  Widget _buildTile(String title) {
    return Card(
      elevation: 4, // Adds shadow effect to each tile
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Spacing between tiles
      child: ListTile(
        title: Text(title),
      ),
    );
  }
}

// Dummy Add Entry Page (Replace with your actual page)
class AddEntryPage extends StatelessWidget {
  const AddEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Entry'),
      ),
      body: const Center(
        child: Text('Add Entry Page'),
      ),
    );
  }
}

