import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final TextEditingController _nameController = TextEditingController();
final TextEditingController _quantityController = TextEditingController();
bool _checkBox = false;

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _items = []; // <3> List of item

  final _shoppingBox = Hive.box('shopping_box');
  List<bool> checkBoxList = [];

// <4> variable of the box we was created it
  @override
  void initState() {
    super.initState();
    _refreshItems(); //  <5> Load data when app starts
  }

  // <6> Get all items from the database
  void _refreshItems() {
    final data = _shoppingBox.keys.map((key) {
      final value = _shoppingBox.get(key);
      return {"key": key, "name": value["name"], "quantity": value['quantity']};
    }).toList();

    setState(() {
      _items = data.reversed.toList();
      checkBoxList = List.generate(_items.length, (index) => false);
      //  <7> we use "reversed" to sort items in order from the latest to the oldest
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pioneers'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              bool itemDelete=false;
              for(int i=0;i<checkBoxList.length;i++){
                if(checkBoxList[i]){
                  _deleteItem(_items[i]['key']);
itemDelete=true;
                }
              }
              if(itemDelete==false){
                _checkBox=true;
              }
              setState(() {});
            }

            // _clearAllItems();
            // for( var xx in _items){
            //   _deleteItem(xx['key']);
            // }
            ,
            icon: const Icon(Icons.delete),
            // tooltip: 'Delete All',
          ),
        ],
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text(
                'No Data',
                style: TextStyle(fontSize: 30),
              ),
            )
          : ListView.builder(
              // the list of items
              itemCount: _items.length,
              itemBuilder: (_, index) {
                final currentItem = _items[index];
                return Card(
                  color: Colors.orange.shade100,
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  child: ListTile(
                      title: Text(currentItem['name']),
                      subtitle: Text(currentItem['quantity'].toString()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit button
                          IconButton(
                              icon: const Icon(Icons.edit),
                              // ignore: avoid_returning_null_for_void
                              onPressed: () =>
                                  _showForm(context, currentItem['key'])),
                          // Delete button
                          IconButton(
                            icon: const Icon(Icons.delete),
                            // ignore: avoid_returning_null_for_void
                            onPressed: () => _deleteItem(currentItem['key']),
                            // _deleteItem(currentItem['key']),
                          ),
                          _checkBox == true
                              ? Checkbox(
                                  value: checkBoxList[index],
                                  onChanged: (value) {
                                    checkBoxList[index]=value!;
                                    setState(() {
                                      
                                    });
                                  })
                              : Container()
                        ],
                      )),
                );
              }),
      // Add new item button
      floatingActionButton: FloatingActionButton(
        // ignore: avoid_returning_null_for_void
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    if (_nameController.text.isNotEmpty) {
      if (_quantityController.text.isNotEmpty) {
        await _shoppingBox.add(newItem);
        _refreshItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(" the  quantity is empty")));
      }
      // update the UI
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(" the name  is empty")));
    }
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    // itemKey == null -> create new item
    // itemKey != null -> update an existing item

    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);
      _nameController.text = existingItem['name'];
      _quantityController.text = existingItem['quantity'];
    }

    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  top: 15,
                  left: 15,
                  right: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: const InputDecoration(hintText: 'Quantity'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new item
                      if (itemKey == null) {
                        _createItem({
                          "name": _nameController.text,
                          "quantity": _quantityController.text
                        });
                      }

                      // update an existing item
                      if (itemKey != null) {
                        _updateItem(itemKey, {
                          'name': _nameController.text.trim(),
                          'quantity': _quantityController.text.trim()
                        });
                      }

                      // Clear the text fields
                      _nameController.text = '';
                      _quantityController.text = '';

                      Navigator.of(ctx).pop(); // Close the bottom sheet
                    },
                    child: Text(itemKey != null ? 'Updat now' : ' Create New'),
                  ),
                  const SizedBox(
                    height: 15,
                  )
                ],
              ),
            )).then((value) {
      _nameController.text = "";
      _quantityController.text = "";
    });
  }

// Delete a single item
  // ignore: unused_element
  Future<void> _deleteItem(int itemKey) async {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed: () async {
        await _shoppingBox.delete(itemKey);
        Navigator.of(context).pop();

        _refreshItems(); // update the UI

        // Display a snackbar
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('An item has been deleted')));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Are you sure?"),
      content: const Text("Would you like to delete the item with id?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _shoppingBox.put(itemKey, item);
    _refreshItems(); // Update the UI
  }

  Future<void> _deleteMoreItem(int itemKey, Map<String, dynamic> item) async {
    // set up the buttons
    await _shoppingBox.deleteAll([itemKey, item]);

    _refreshItems(); // update the UI
  }
}
  // Create new item
  
