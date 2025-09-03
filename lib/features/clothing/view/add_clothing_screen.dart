// lib/features/clothing/view/add_clothing_screen.dart

import 'dart:developer';
import 'dart:io';
import 'package:engage_app/features/clothing/cubit/clothing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class AddClothingScreen extends StatefulWidget {
  const AddClothingScreen({super.key});
  @override
  State<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _picker = ImagePicker();
  
  XFile? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma imagem.'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await context.read<ClothingCubit>().addClothingItem(
              name: _nameController.text,
              category: _categoryController.text,
              imageFile: File(_imageFile!.path),
            );
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        log('Erro ao submeter formulário: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha ao adicionar item: ${e.toString()}'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Nova Peça')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seletor de Imagem
              Center(
                child: GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery), // Padrão é galeria
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _imageFile == null
                        ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeria'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Câmera'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Campos de texto
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome da Peça'),
                validator: (value) => value == null || value.isEmpty ? 'Por favor, insira um nome.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Categoria'),
                validator: (value) => value == null || value.isEmpty ? 'Por favor, insira uma categoria.' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3))
                    : const Text('Salvar Peça'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}