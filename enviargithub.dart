import 'dart:io';

void main() async {
  print('===================================================');
  print('🚀 Agente Interactivo: Subir proyecto a GitHub 🚀');
  print('===================================================\n');

  // 1. Pedir el link del repositorio
  stdout.write('1️⃣  Ingresa la URL del nuevo repositorio en GitHub:\n> ');
  String? url = stdin.readLineSync()?.trim();
  
  if (url == null || url.isEmpty) {
    print('❌ Error: La URL no puede estar vacía. Proceso cancelado.');
    return;
  }

  // 2. Pedir mensaje del commit
  stdout.write('\n2️⃣  Ingresa el mensaje para el commit:\n> ');
  String? commitMessage = stdin.readLineSync()?.trim();
  
  if (commitMessage == null || commitMessage.isEmpty) {
    print('❌ Error: El mensaje del commit no puede estar vacío. Proceso cancelado.');
    return;
  }

  // 3. Pedir el nombre de la rama (por defecto 'main')
  stdout.write('\n3️⃣  Ingresa el nombre de la rama (Presiona Enter para usar "main" por defecto):\n> ');
  String? branch = stdin.readLineSync()?.trim();
  
  if (branch == null || branch.isEmpty) {
    branch = 'main';
    print('   -> Seleccionada rama por defecto: main');
  } else {
    print('   -> Seleccionada rama: $branch');
  }

  print('\n⏳ Iniciando proceso de carga a GitHub...\n');

  // Función interna para ejecutar comandos de consola
  Future<bool> runCommand(String command, List<String> args) async {
    print('   Ejecutando: $command ${args.join(' ')}');
    var result = await Process.run(command, args);
    
    if (result.exitCode != 0) {
      String errorMessage = result.stderr.toString().trim();
      String outputMessage = result.stdout.toString().trim();
      
      // Controlar el error de "nothing to commit" que no debería detener el proceso
      if (args.contains('commit') && (errorMessage.contains('nothing to commit') || outputMessage.contains('nothing to commit'))) {
        print('   ✅ Nota: No hay archivos nuevos para hacer commit (continuando)');
        return true;
      }
      
      print('\n❌ Ocurrió un error al ejecutar comando:');
      print(errorMessage);
      return false; // Error inesperado
    }
    return true; // Ejecución correcta
  }

  // Flujo completo de sentencias de Git
  
  // git init (por si el respositorio no está inicializado)
  if (!await runCommand('git', ['init'])) return;

  // git add .
  if (!await runCommand('git', ['add', '.'])) return;

  // git commit -m "mensaje"
  await runCommand('git', ['commit', '-m', commitMessage]);

  // git branch -M rama
  if (!await runCommand('git', ['branch', '-M', branch])) return;

  // Asegurar que si existe un origen antiguo se actualice, 
  // lo removemos silenciosamente e ignoramos su salida
  await Process.run('git', ['remote', 'remove', 'origin']);

  // git remote add origin URL
  if (!await runCommand('git', ['remote', 'add', 'origin', url])) return;

  // git push -u origin rama
  print('\n🚀 Subiendo los archivos, por favor espera...');
  if (!await runCommand('git', ['push', '-u', 'origin', branch])) return;

  print('\n🎉 ¡Fantástico! Tu proyecto y tus cambios han sido subidos a GitHub exitosamente. 🎉');
  print('===================================================');
}
