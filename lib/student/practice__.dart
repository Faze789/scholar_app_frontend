import 'package:flutter/material.dart';

class practice__ extends StatefulWidget {
  practice__({super.key});

  @override
  State<practice__> createState() => _practice__State();
}

class _practice__State extends State<practice__> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();

  final list = ["computer science", "civil", "mechanical", "electrical"];

  final Map<String, dynamic> data = {
    "name": "fazal",
    "age": 23,
    "weight": 84.5,
  };

  int? check; // <-- only this is needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Simple UI"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Basic Information",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: name,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: email,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phone,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: check == index,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          check = index;
                        } else {
                          check = null;
                        }
                      });
                    },
                  ),
                  title: Text(list[index]),
                );
              },
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  get_data();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void get_data() {
    print("\n\n");

    for (var i in data.entries) {
      print(i.key);
    }

    print("----------------------------\n");
    print("Name : ${name.text}");
    print("email : ${email.text}");
    print("contact :${phone.text}");

    if (check != null) {
      print("Selected Field: ${list[check!]}");
    } else {
      print("No field selected");
    }
  }
}
