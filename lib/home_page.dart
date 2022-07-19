import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:secured_note_app/auth_page.dart';
import 'package:secured_note_app/constants.dart';
import 'package:secured_note_app/details_page.dart';
import 'package:secured_note_app/model/note_model.dart';
import 'package:secured_note_app/widgets/alert_dialog.dart';
import 'package:secured_note_app/widgets/my_bottom_appbar.dart';
import 'package:secured_note_app/extensions/firestore_x.dart';
import 'package:share_plus/share_plus.dart';
import './extensions/toast_x.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void deleteNote(String id, String title, BuildContext context) {
    firestore.deleteNote(id).whenComplete(() => {
          'Note $title deleted successfully'.showToast(context),
        });
  }

  bool isFavListSelected = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder(
            stream: firestore.showNotes(isFavList: isFavListSelected),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Notes Available,\nTap "+" Button to Add Notes',
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  return GridView.builder(
                    itemCount: snapshot.data!.docs.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 2 / 2.1,
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemBuilder: (context, index) {
                      final convertedValue = Note.fromJson(
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>,
                      );

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                isEditing: true,
                                note: Note(
                                  title: convertedValue.title!,
                                  bodyColor: convertedValue.bodyColor!,
                                  isFav: convertedValue.isFav!,
                                  color: convertedValue.color!,
                                  description: convertedValue.description!,
                                ),
                                id: snapshot.data!.docs[index].id,
                              ),
                            ),
                          );
                        },
                        onLongPress: () {
                          BlurryDialog alert = BlurryDialog(
                            title: 'Delete Note',
                            content:
                                'Are you sure you want to delete this note?',
                            onContinue: () {
                              deleteNote(
                                snapshot.data!.docs[index].id,
                                convertedValue.title!,
                                context,
                              );
                            },
                          );
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return alert;
                            },
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(convertedValue.bodyColor!),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                child: Container(
                                  height: 60,
                                  width: size.width / 2.2,
                                  alignment: Alignment.center,
                                  color: Color(convertedValue.color!),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        width: size.width / 6.6,
                                        child: Text(
                                          convertedValue.title!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.share,
                                                size: 15,
                                              ),
                                              onPressed: () {
                                                Share.share(
                                                  '${convertedValue.title} - ${convertedValue.description}',
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 20,
                                            child: IconButton(
                                              onPressed: () async {
                                                firestore
                                                    .updateFav(
                                                        snapshot.data!
                                                            .docs[index].id,
                                                        !convertedValue.isFav!)
                                                    .whenComplete(
                                                      () =>
                                                          '${convertedValue.title} is ${convertedValue.isFav! ? "deleted from" : "added to"} favourite'
                                                              .showToast(
                                                                  context),
                                                    );
                                              },
                                              icon: Icon(
                                                Icons.favorite,
                                                size: 16,
                                                color: convertedValue.isFav!
                                                    ? Colors.redAccent
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Updated: ${DateFormat.yMd().add_jm().format(DateTime.fromMicrosecondsSinceEpoch(convertedValue.modifiedAt!))}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 10),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  convertedValue.description!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
      bottomNavigationBar: MyBottomAppbar(
        onFavPressed: () {
          setState(() {
            isFavListSelected = !isFavListSelected;
          });
        },
        onExitPressed: () {
          firebaseAuth.signOut().whenComplete(
                () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const AuthPage(),
                  ),
                ),
              );
          "You have been signed out".showToast(context);
        },
        isFavActive: isFavListSelected,
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const DetailsPage(
                isEditing: false,
              ),
            ),
          );
        },
        child: const Icon(FontAwesomeIcons.plus),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
