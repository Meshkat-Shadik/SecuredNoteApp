import 'package:flutter/material.dart';
import 'package:secured_note_app/calender_page.dart';
import 'package:secured_note_app/constants.dart';
import 'package:secured_note_app/model/accounts_model.dart';
import 'package:secured_note_app/widgets/list_items.dart';
import '../extensions/firestore_x.dart';
import '../extensions/toast_x.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  String? dropdownValue;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Accounting'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalenderScreen(),
                ),
              );
            },
            icon: const Icon(Icons.calendar_month_rounded),
          )
        ],
      ),
      body: ListItems(
        scaffoldKey: _scaffoldKey,
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context) {
              return const BottomSheetWidget(
                isEditing: false,
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({
    Key? key,
    required this.isEditing,
    this.accountDetails,
    this.id,
  }) : super(key: key);
  final bool isEditing;
  final AccountModel? accountDetails;
  final String? id;

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  int defaultChoiceIndex = 0;
  final List<String> _choicesList = ['Cost', 'Deposit'];
  TextEditingController? _titleController;
  TextEditingController? _amountController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.accountDetails?.title ?? '',
    );
    _amountController = TextEditingController(
      text: widget.accountDetails?.amount.toString() ?? '',
    );
    if (mounted) {
      if (widget.isEditing) {
        defaultChoiceIndex = widget.accountDetails!.type == 'Cost' ? 0 : 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: 500,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(38, 50, 56, 1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      '${widget.isEditing ? "Edit" : "Add"} Cost / Deposit',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Wrap(
                      spacing: 8,
                      children: List.generate(_choicesList.length, (index) {
                        return ChoiceChip(
                          backgroundColor: const Color(0xff1C272B),
                          labelPadding: const EdgeInsets.all(2.0),
                          label: Text(
                            _choicesList[index],
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(color: Colors.white, fontSize: 14),
                          ),
                          selected: defaultChoiceIndex == index,
                          selectedColor: const Color(0xff63B4D4),
                          onSelected: (value) {
                            //print(_choicesList[defaultChoiceIndex]);
                            setState(() {
                              defaultChoiceIndex =
                                  value ? index : defaultChoiceIndex;
                            });
                          },
                          // backgroundColor: color,
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 20),
                        hintText: 'Title',
                        hintStyle: TextStyle(letterSpacing: 2),
                        border: OutlineInputBorder(),
                      ),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Please provide a title';
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 20),
                        hintText: 'Amount',
                        hintStyle: TextStyle(letterSpacing: 2),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (String? value) {
                        if (RegExp(r'''^-?\d+\.?\d*$''').hasMatch(value!) ==
                            false) {
                          return 'Only Numbers are allowed';
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      height: 50,
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () async {
                          final FormState form = _formKey.currentState!;
                          if (form.validate()) {
                            final newAccountData = AccountModel(
                              title: _titleController!.text,
                              type: _choicesList[defaultChoiceIndex],
                              amount:
                                  int.tryParse(_amountController!.text) ?? 0,
                            );
                            if (widget.isEditing) {
                              if (widget.accountDetails == newAccountData) {
                                Navigator.pop(context);
                                "No changes made".showToast(context);
                              } else {
                                await firestore
                                    .updateAccount(widget.id!, newAccountData)
                                    .whenComplete(
                                  () {
                                    Navigator.pop(context);
                                    "Record updated successfully"
                                        .showToast(context);
                                  },
                                );
                              }
                            } else {
                              firestore.addAccount(
                                AccountModel(
                                  title: _titleController!.text.trim(),
                                  type: _choicesList[defaultChoiceIndex],
                                  amount:
                                      int.tryParse(_amountController!.text) ??
                                          0,
                                ),
                              );
                            }
                          } else {
                            "Please fill all the fields".showToast(context);
                          }
                        },
                        child: Text(
                          widget.isEditing ? 'UPDATE' : 'ADD',
                          style: const TextStyle(letterSpacing: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController?.dispose();
    _amountController?.dispose();
    super.dispose();
  }
}
