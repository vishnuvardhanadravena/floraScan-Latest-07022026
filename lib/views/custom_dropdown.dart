import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final Widget? prefixIcon;

  const CustomDropdown({
    super.key,
    required this.hint,
    this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (prefixIcon != null) ...[prefixIcon!, const SizedBox(width: 12)],
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Colors.white,
                value: value,
                hint: Text(hint, style: const TextStyle(color: Colors.black)),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black,
                ),
                items:
                    items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/cupertino.dart';

// class CustomDropdown extends StatelessWidget {
//   final String hint;
//   final String? value;
//   final List<String> items;
//   final ValueChanged<String?> onChanged;
//   final Widget? prefixIcon;

//   const CustomDropdown({
//     super.key,
//     required this.hint,
//     this.value,
//     required this.items,
//     required this.onChanged,
//     this.prefixIcon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           if (prefixIcon != null) ...[
//             prefixIcon!,
//             const SizedBox(width: 12),
//           ],
//           Expanded(
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: value,
//                 isExpanded: true,
//                 icon: const Icon(Icons.keyboard_arrow_down),
//                 hint: Text(
//                   hint,
//                   style: const TextStyle(color: Colors.black),
//                 ),
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 16,
//                 ),
//                 items: items.map((String item) {
//                   return DropdownMenuItem<String>(
//                     value: item,
//                     child: const Text(
//                       '', // placeholder, replaced below
//                     ),
//                   );
//                 }).toList(),
//                 selectedItemBuilder: (context) {
//                   return items.map((item) {
//                     return Text(
//                       item,
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontSize: 16,
//                       ),
//                     );
//                   }).toList();
//                 },
//                 onChanged: onChanged,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
