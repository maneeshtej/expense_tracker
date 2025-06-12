 // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      //     Expanded(
                      //       flex: 3,
                      //       child: AspectRatio(
                      //         aspectRatio: 1.2,
                      //         child: PieChart(
                      //           PieChartData(
                      //             sections: _tagExpenses.entries.map((entry) {
                      //               final tag = entry.key;
                      //               final amount = entry.value as double;
                      //               final color = Color(
                      //                 tag.colorValue ?? 0xFFFFFFFF,
                      //               );

                      //               final total = _tagExpenses.values
                      //                   .fold<double>(
                      //                     0,
                      //                     (sum, val) => sum + (val as double),
                      //                   );

                      //               final percentage = (amount / total) * 100;

                      //               return PieChartSectionData(
                      //                 color: color,
                      //                 value: amount,
                      //                 title:
                      //                     '${percentage.toStringAsFixed(1)}%',
                      //                 radius: 40,
                      //                 titleStyle: TextStyle(
                      //                   fontSize: 12,
                      //                   fontWeight: FontWeight.bold,
                      //                   color: Colors.black,
                      //                 ),
                      //               );
                      //             }).toList(),
                      //             sectionsSpace: 2,
                      //             centerSpaceRadius: 40,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(width: 10),
                      //     Expanded(
                      //       flex: 2,
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: _tagExpenses.entries.map((entry) {
                      //           final tag = entry.key;
                      //           final amount = entry.value as double;
                      //           final color = Color(
                      //             tag.colorValue ?? 0xFFFFFFFF,
                      //           );

                      //           return Padding(
                      //             padding: const EdgeInsets.symmetric(
                      //               vertical: 4,
                      //             ),
                      //             child: Row(
                      //               children: [
                      //                 Container(
                      //                   width: 12,
                      //                   height: 12,
                      //                   decoration: BoxDecoration(
                      //                     color: color,
                      //                     shape: BoxShape.circle,
                      //                   ),
                      //                 ),
                      //                 SizedBox(width: 6),
                      //                 Expanded(
                      //                   child: Text(
                      //                     "${tag.name} - ₹${amount.toStringAsFixed(2)}",
                      //                     style: TextStyle(
                      //                       fontSize: 12,
                      //                       color: Colors.white,
                      //                     ),
                      //                     overflow: TextOverflow.ellipsis,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           );
                      //         }).toList(),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(height: 20),

                      // Divider(),
                      // SizedBox(height: 20),
                      // SingleChildScrollView(
                      //   scrollDirection: Axis.horizontal,
                      //   child: Row(
                      //     children: ["Today", "Weekly", "Monthly", "Yearly"].map(
                      //       (option) {
                      //         return GestureDetector(
                      //           onTap: () async {
                      //             setState(() {
                      //               _selectedExpensesDurationToDisplay = option;
                      //             });

                      //             await _scrollController.animateTo(
                      //               0,
                      //               duration: Duration(milliseconds: 200),
                      //               curve: Curves.easeOut,
                      //             );

                      //             await _getAllExpensesByTime();
                      //             await _getAllTagsWithExpensesByDuration();
                      //           },
                      //           child: Container(
                      //             margin: EdgeInsets.only(right: 10),
                      //             padding: EdgeInsets.symmetric(
                      //               vertical: 7,
                      //               horizontal: 20,
                      //             ),
                      //             decoration: BoxDecoration(
                      //               color:
                      //                   (_selectedExpensesDurationToDisplay ==
                      //                       option)
                      //                   ? Colors.white
                      //                   : Colors.grey.shade900,
                      //               borderRadius: BorderRadius.circular(30),
                      //             ),
                      //             child: Text(
                      //               option,
                      //               style: TextStyle(
                      //                 color:
                      //                     (_selectedExpensesDurationToDisplay ==
                      //                         option)
                      //                     ? Colors.black
                      //                     : Colors.white,
                      //               ),
                      //             ),
                      //           ),
                      //         );
                      //       },
                      //     ).toList(),
                      //   ),
                      // ),

                      // // Expenses List (as Column)
                      // Column(
                      //   children: _expenses.map((expense) {
                      //     return ListTile(
                      //       contentPadding: const EdgeInsets.symmetric(
                      //         vertical: 10,
                      //         horizontal: 16,
                      //       ),
                      //       title: Text(
                      //         "₹${expense.amount.toStringAsFixed(2)}",
                      //         style: const TextStyle(color: Colors.white),
                      //       ),
                      //       subtitle: Row(
                      //         crossAxisAlignment: CrossAxisAlignment.center,
                      //         children: [
                      //           Text(expense.tag.value?.name ?? "Unknown"),
                      //           const SizedBox(width: 10),
                      //           Text(
                      //             expense.recieverName ?? "Unknown",
                      //             style: TextStyle(
                      //               color: Colors.grey.shade600,
                      //               fontSize: 12,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //       trailing: Column(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         crossAxisAlignment: CrossAxisAlignment.end,
                      //         children: [
                      //           Text(
                      //             DateFormat.jm().format(expense.timeStamp),
                      //             style: const TextStyle(
                      //               color: Colors.white,
                      //               fontSize: 13,
                      //               fontWeight: FontWeight.w500,
                      //             ),
                      //           ),
                      //           const SizedBox(height: 4),
                      //           Text(
                      //             DateFormat(
                      //               "dd MMM",
                      //             ).format(expense.timeStamp),
                      //             style: TextStyle(
                      //               color: Colors.grey.shade500,
                      //               fontSize: 11,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //       leading: Container(
                      //         height: 10,
                      //         width: 10,
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(40),
                      //           color: Color(
                      //             expense.tag.value?.colorValue ?? 0xFFFFFFFF,
                      //           ),
                      //         ),
                      //       ),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(10),
                      //       ),
                      //     );
                      //   }).toList(),
                      // ),