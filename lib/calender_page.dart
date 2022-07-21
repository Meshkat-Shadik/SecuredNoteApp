import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:secured_note_app/widgets/list_items.dart';
import 'package:table_calendar/table_calendar.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({Key? key}) : super(key: key);

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

final kNow = DateTime.now();
final kFirstDay = DateTime(kNow.year - 3, kNow.month - 3, kNow.day);
final kLastDay = DateTime(kNow.year + 3, kNow.month + 3, kNow.day);

class _CalenderScreenState extends State<CalenderScreen> {
  String? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calender'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Card(
                      elevation: 10,
                      child: TableCalendar(
                        focusedDay: kNow,
                        firstDay: kFirstDay,
                        lastDay: kLastDay,
                        weekendDays: const [
                          DateTime.friday,
                          DateTime.saturday,
                        ],
                        onFormatChanged: (_) {},
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekendStyle: TextStyle(color: Colors.red.shade200),
                          weekdayStyle: const TextStyle(color: Colors.white),
                        ),
                        headerStyle: HeaderStyle(
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade800,
                          ),
                          headerMargin: const EdgeInsets.only(bottom: 8.0),
                          titleTextStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          formatButtonDecoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          formatButtonTextStyle:
                              const TextStyle(color: Colors.white),
                        ),
                        calendarStyle: CalendarStyle(
                          weekendTextStyle: TextStyle(
                            color: Colors.red.shade200,
                          ),
                        ),
                        calendarBuilders: const CalendarBuilders(),
                        onDaySelected: (selectedDay, _) {
                          // print('$selectedDay');
                          setState(() {
                            selectedDate =
                                DateFormat('dd-MM-yyyy').format(selectedDay);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    selectedDate == null
                        ? const Text('Select a Date to see the record')
                        : Text('Selected date: $selectedDate'),
                  ],
                ),
              ),
              selectedDate == null
                  ? Container()
                  : Card(
                      elevation: 10,
                      child: SizedBox(
                        height: 200,
                        child: ListItems(
                          accountDate: selectedDate,
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
