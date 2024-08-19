import 'package:flutter/material.dart';
import 'dart:io';
import 'project_details_page.dart';

class ProjectGalleryPage extends StatefulWidget {
  final Directory baseDir;

  const ProjectGalleryPage({Key? key, required this.baseDir}) : super(key: key);

  @override
  _ProjectGalleryPageState createState() => _ProjectGalleryPageState();
}

class _ProjectGalleryPageState extends State<ProjectGalleryPage> {
  late List<Directory> projects;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    setState(() {
      // Recarrega a lista de projetos a partir do diretório base
      projects = widget.baseDir
          .listSync()
          .whereType<Directory>()
          .toList();
    });
  }

  Future<void> _deleteProject(Directory projectDir) async {
    try {
      if (await projectDir.exists()) {
        await projectDir.delete(recursive: true);
        _loadProjects(); // Atualiza a lista de projetos
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting project: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects, // Recarrega a lista de projetos
          ),
        ],
      ),
      body: projects.isEmpty
          ? const Center(child: Text('No projects found.'))
          : ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final projectDir = projects[index];
          final videoFile = File('${projectDir.path}/video.mp4');
          final framesDir = Directory('${projectDir.path}/frames');

          return Card(
            child: ListTile(
              title: Text('Project ${projectDir.path.split('/').last}'),
              subtitle: Text('Contains video and frames'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProjectDetailsPage(
                      videoPath: videoFile.path,
                      framesDirPath: framesDir.existsSync() ? framesDir.path : null, projectPath: '',
                    ),
                  ),
                ).then((_) => _loadProjects()); // Recarrega ao voltar
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteProject(projectDir),
              ),
            ),
          );
        },
      ),
    );
  }
}
