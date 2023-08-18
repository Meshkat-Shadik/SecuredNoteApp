import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:secured_note_app/constants.dart';
import 'package:secured_note_app/expense_page.dart';
import 'package:secured_note_app/extensions/firestore_x.dart';
import 'package:secured_note_app/extensions/toast_x.dart';
import 'package:secured_note_app/model/accounts_model.dart';
import 'package:secured_note_app/widgets/alert_dialog.dart';

class ListItems extends StatefulWidget {
  const ListItems({
    Key? key,
    this.scaffoldKey,
    this.accountDate,
  }) : super(key: key);
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String? accountDate;

  @override
  State<ListItems> createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {
  int totalCost = 0;

  int? getTotal(
      List<QueryDocumentSnapshot<Object?>> snapshotData, String type) {
    if (mounted) {
      return snapshotData.fold<int>(
        0,
        (prev, current) =>
            prev +
            ((AccountModel.fromJson(current.data() as Map<String, dynamic>)
                        .type) ==
                    type
                ? (AccountModel.fromJson(current.data() as Map<String, dynamic>)
                    .amount)
                : 0),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firestore.showAccount(
        widget.accountDate == null
            ? DateFormat('dd-MM-yyyy').format(
                DateTime.fromMicrosecondsSinceEpoch(
                    DateTime.now().microsecondsSinceEpoch))
            : widget.accountDate!,
      ),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No Records Available,\n${widget.accountDate == null ? 'Tap "+" Button to Add Records' : ''}',
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final accountDetails = AccountModel.fromJson(
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>);
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0, bottom: 4.0, top: 4.0),
                          child: Dismissible(
                            key: Key(snapshot.data!.docs[index].id),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Text(
                                'Slide to Delete this Record',
                              ),
                            ),
                            direction: widget.scaffoldKey == null
                                ? DismissDirection.none
                                : DismissDirection.endToStart,
                            confirmDismiss: (direction) {
                              return showDialog(
                                context: widget.scaffoldKey!.currentContext!,
                                builder: (context) {
                                  return BlurryDialog(
                                    title: 'Warning ⚠',
                                    content:
                                        'Do you want to delete this record?',
                                    onContinue: () async {
                                      await firestore
                                          .deleteAccount(
                                            snapshot.data!.docs[index].id,
                                          )
                                          .then(
                                            (value) =>
                                                "Record Deleted Successfully"
                                                    .showToast(widget
                                                        .scaffoldKey!
                                                        .currentContext!),
                                            onError: (e) => e
                                                .toString()
                                                .showToast(widget.scaffoldKey!
                                                    .currentContext!),
                                          );
                                    },
                                  );
                                },
                              );
                            },
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: accountDetails.type == 'Cost'
                                      ? redColor
                                      : greenColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              contentPadding:
                                  const EdgeInsets.only(right: 0, left: 10),
                              horizontalTitleGap: 5,
                              leading: accountDetails.type == 'Cost'
                                  ? const Icon(Icons.money_off)
                                  : const Icon(Icons.attach_money),
                              title: Text(
                                accountDetails.title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.only(left: 5),
                                width: 150,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      accountDetails.amount.toString(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    widget.accountDate == null
                                        ? IconButton(
                                            onPressed: () {
                                              showModalBottomSheet(
                                                backgroundColor:
                                                    Colors.transparent,
                                                context: context,
                                                builder: (context) {
                                                  return BottomSheetWidget(
                                                    isEditing: true,
                                                    accountDetails:
                                                        accountDetails,
                                                    id: snapshot
                                                        .data!.docs[index].id,
                                                  );
                                                },
                                              );
                                            },
                                            icon: const Icon(Icons.edit),
                                          )
                                        : const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade900,
                    border: Border(
                      top: BorderSide(
                        color: Colors.blueGrey.shade400,
                        width: 5,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TotalCostIncomeRow(
                        value: getTotal(snapshot.data!.docs, 'Cost')!,
                        type: 'Cost',
                      ),
                      TotalCostIncomeRow(
                        value: getTotal(snapshot.data!.docs, 'Deposit')!,
                        type: 'Deposit',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class TotalCostIncomeRow extends StatelessWidget {
  const TotalCostIncomeRow({
    Key? key,
    required this.value,
    required this.type,
  }) : super(key: key);
  final int value;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'Total $type',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: type == 'Cost' ? Colors.red : greenColor,
          ),
        ),
        Text(
          //.toString(),
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: type == 'Cost' ? Colors.red : greenColor,
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}
