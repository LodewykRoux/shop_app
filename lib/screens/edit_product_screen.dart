import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Product? product;
  const EditProductScreen({super.key, this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();

  final _imageUrlController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Product _editedProduct =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _editedProduct = widget.product!;
      _imageUrlController.text = _editedProduct.imageUrl;
    }
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() {
      _isLoading = true;
    });
    _formKey.currentState?.save();
    final providerState = Provider.of<ProductProvider>(context, listen: false);
    if (widget.product != null) {
      await providerState.updateProduct(_editedProduct);
    } else {
      try {
        await providerState.addProduct(_editedProduct);
      } catch (e) {
        return showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('An error occurred'),
            content: const Text(
              'Something went wrong',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Okay'),
              )
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(
              Icons.save,
            ),
          )
        ],
      ),
      body: Visibility(
        visible: !_isLoading,
        replacement: const Center(child: CircularProgressIndicator()),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: _editedProduct.title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_priceFocusNode);
                    },
                    onSaved: (newValue) {
                      _editedProduct = _editedProduct.copyWith(title: newValue);
                    },
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Required';
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _editedProduct.price.toString(),
                    focusNode: _priceFocusNode,
                    decoration: const InputDecoration(labelText: 'Price'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode);
                    },
                    onSaved: (newValue) {
                      _editedProduct = _editedProduct.copyWith(
                        price: double.tryParse(
                          newValue ?? '${_editedProduct.price}',
                        ),
                      );
                    },
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Required';
                      if (double.tryParse(value!) == null) {
                        return 'Invalid Number';
                      }
                      if (double.tryParse(value)! <= 0) {
                        return 'Invalid Number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _editedProduct.description,
                    focusNode: _descriptionFocusNode,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    onSaved: (newValue) {
                      _editedProduct = _editedProduct.copyWith(
                        description: newValue,
                      );
                    },
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Required';

                      return null;
                    },
                  ),
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(top: 8.0, right: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          ),
                        ),
                        child: _imageUrlController.text.isEmpty
                            ? const Center(
                                child: Text('Enter a URL'),
                              )
                            : FittedBox(
                                child: Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Image URL'),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          controller: _imageUrlController,
                          focusNode: _imageUrlFocusNode,
                          onEditingComplete: () {
                            setState(() {});
                          },
                          onFieldSubmitted: (_) {
                            _saveForm();
                          },
                          onSaved: (newValue) {
                            _editedProduct = _editedProduct.copyWith(
                              imageUrl: newValue,
                            );
                          },
                          validator: (value) {
                            if (value?.isEmpty == true) return 'Required';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
