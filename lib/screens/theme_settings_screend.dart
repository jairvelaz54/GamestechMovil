import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gamestech/settings/theme_provider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Tema'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecciona el tema:'),
            SwitchListTile(
              title: const Text('Modo oscuro'),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
            const SizedBox(height: 20),
            const Text('Selecciona la fuente:'),
            DropdownButton<String>(
              value: themeProvider.fontFamily,
              items: const [
                DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
                DropdownMenuItem(value: 'OpenSans', child: Text('Open Sans')),
                DropdownMenuItem(value: 'Lato', child: Text('Lato')),
                DropdownMenuItem(value: 'Montserrat', child: Text('Montserrat')),
              ],
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setFontFamily(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
