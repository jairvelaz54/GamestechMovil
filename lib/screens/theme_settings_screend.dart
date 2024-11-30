import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gamestech/settings/theme_provider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Tema'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                'Personaliza tu experiencia',
                style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              ),
              const SizedBox(height: 10),
              Text(
                'Selecciona un tema y una fuente para la aplicación.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),

              // Tema
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.color_lens, size: 28),
                          const SizedBox(width: 10),
                          Text(
                            'Selecciona el tema',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SwitchListTile(
                        title: const Text('Modo oscuro'),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Fuentes
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.font_download, size: 28),
                          const SizedBox(width: 10),
                          Text(
                            'Selecciona la fuente',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: themeProvider.fontFamily,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Roboto', child: Text('Roboto')),
                          DropdownMenuItem(
                              value: 'Open Sans', child: Text('Open Sans')),
                          DropdownMenuItem(value: 'Lato', child: Text('Lato')),
                          DropdownMenuItem(
                              value: 'Montserrat',
                              child: Text('Montserrat')),
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
              ),

             
            ],
          ),
        ),
      ),
    );
  }
}
