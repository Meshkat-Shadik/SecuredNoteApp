import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:secured_note_app/constants.dart';
import 'package:secured_note_app/model/accounts_model.dart';
import 'package:secured_note_app/widgets/alert_dialog.dart';
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
            onPressed: () {},
            icon: const Icon(Icons.calendar_month_rounded),
          )
        ],
      ),
      body: StreamBuilder(
        stream: firestore.showAccount(
          DateFormat('dd-MM-yyyy').format(
            DateTime.fromMicrosecondsSinceEpoch(
                DateTime.now().microsecondsSinceEpoch),
          ),
        ),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No Records Available,\nTap "+" Button to Add Records',
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return ListView.separated(
                separatorBuilder: (context, index) => const Divider(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: ((context, index) {
                  final accountDetails = AccountModel.fromJson(
                      snapshot.data!.docs[index].data()
                          as Map<String, dynamic>);
                  return Dismissible(
                    key: Key(snapshot.data!.docs[index].id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Text(
                        'Slide to Delete this Record',
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) {
                      return showDialog(
                        context: _scaffoldKey.currentContext!,
                        builder: (context) {
                          return BlurryDialog(
                            title: 'Warning ⚠',
                            content: 'Do you want to delete this record?',
                            onContinue: () async {
                              await firestore
                                  .deleteAccount(
                                    snapshot.data!.docs[index].id,
                                  )
                                  .then(
                                    (value) => "Record Deleted Successfully"
                                        .showToast(
                                            _scaffoldKey.currentContext!),
                                    onError: (e) => e.toString().showToast(
                                        _scaffoldKey.currentContext!),
                                  );
                            },
                          );
                        },
                      );
                    },
                    child: ListTile(
                      tileColor: accountDetails.type == 'Cost'
                          ? Colors.red.shade900
                          : Colors.green.shade900,
                      contentPadding: const EdgeInsets.only(right: 0, left: 10),
                      horizontalTitleGap: 5,
                      leading: accountDetails.type == 'Cost'
                          ? const Icon(Icons.money_off)
                          : const Icon(Icons.attach_money),
                      title: Text(
                        accountDetails.title + '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.only(left: 5),
                        width: 150,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              accountDetails.amount.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (context) {
                                        return BottomSheetWidget(
                                          isEditing: true,
                                          accountDetails: AccountModel(
                                            title: accountDetails.title.trim(),
                                            type: accountDetails.type,
                                            amount: accountDetails.amount,
                                          ),
                                          id: snapshot.data!.docs[index].id,
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 1,
                                  color: Colors.red,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
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
    return Container(
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
                            title: _titleController!.text.trim(),
                            type: _choicesList[defaultChoiceIndex],
                            amount: int.tryParse(_amountController!.text) ?? 0,
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
                                    int.tryParse(_amountController!.text) ?? 0,
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
    );
  }

  @override
  void dispose() {
    _titleController?.dispose();
    _amountController?.dispose();
    super.dispose();
  }
}
