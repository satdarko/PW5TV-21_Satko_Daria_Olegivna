import 'package:flutter/material.dart';

void main() {
  runApp(const Lab5App());
}

class Lab5App extends StatelessWidget {
  const Lab5App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 5 - Var',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CalcScreen(),
    );
  }
}

class CalcScreen extends StatefulWidget {
  const CalcScreen({super.key});

  @override
  State<CalcScreen> createState() => CalcScreenState();
}

class CalcScreenState extends State<CalcScreen> {
  final cWpl = TextEditingController(text: "0.01");
  final cTpl = TextEditingController(text: "30");
  final cWline = TextEditingController(text: "0.07");
  final cTline = TextEditingController(text: "10");
  final cWt = TextEditingController(text: "0.015");
  final cTt = TextEditingController(text: "100");
  final cWv = TextEditingController(text: "0.02");
  final cTv = TextEditingController(text: "15");
  final cWp = TextEditingController(text: "0.18");
  final cTp = TextEditingController(text: "2");
  final cKpMax = TextEditingController(text: "43");
  final cWcb = TextEditingController(text: "0.02");

  final cZnepa = TextEditingController(text: "23.6");
  final cZnepp = TextEditingController(text: "17.6");
  final cWt35 = TextEditingController(text: "0.01");
  final cTbt35 = TextEditingController(text: "0.045");
  final cPm = TextEditingController(text: "5120");
  final cTm = TextEditingController(text: "6451");
  final cKpt35 = TextEditingController(text: "0.004");

  String res1 = "";
  String res2 = "";

  double parse(String s) {
    return double.tryParse(s) ?? 0.0;
  }

  void calculate() {
    double wpl = parse(cWpl.text);
    double tpl = parse(cTpl.text);
    double wline = parse(cWline.text);
    double tline = parse(cTline.text);
    double wt = parse(cWt.text);
    double tt = parse(cTt.text);
    double wv = parse(cWv.text);
    double tv = parse(cTv.text);
    double wp = parse(cWp.text);
    double tp = parse(cTp.text);
    double kpmax = parse(cKpMax.text);
    double wcb = parse(cWcb.text);

    double woc = wpl + wline + wt + wv + wp;
    double tvoc = (wpl * tpl + wline * tline + wt * tt + wv * tv + wp * tp) / woc;
    double kaoc = (woc * tvoc) / 8760;
    double kpoc = 1.2 * kpmax / 8760;
    double wdk = 2 * woc * (kaoc + kpoc);
    double wds = wdk + wcb;

    double znepa = parse(cZnepa.text);
    double znepp = parse(cZnepp.text);
    double wt35 = parse(cWt35.text);
    double tbt35 = parse(cTbt35.text);
    double pm = parse(cPm.text);
    double tm = parse(cTm.text);
    double kpt35 = parse(cKpt35.text);

    double mwneda = wt35 * tbt35 * pm * tm;
    double mwnedp = kpt35 * pm * tm;
    double mznep = znepa * mwneda + znepp * mwnedp;

    setState(() {
      res1 = "Частота відмов одноколової системи: ${woc.toStringAsFixed(5)} рік-1\n"
          "Середня тривалість відновлення: ${tvoc.toStringAsFixed(5)} год\n"
          "Коефіцієнт аварійного простою: ${kaoc.toStringAsFixed(5)}\n"
          "Коефіцієнт планового простою: ${kpoc.toStringAsFixed(5)}\n"
          "Частота відмов одночасно двох кіл: ${wdk.toStringAsFixed(5)} рік-1\n"
          "Частота відмов двоколової системи: ${wds.toStringAsFixed(5)} рік-1";

      res2 = "М.С. аварійного недовідпущення: ${mwneda.toStringAsFixed(2)} кВт*год\n"
          "М.С. планового недовідпущення: ${mwnedp.toStringAsFixed(2)} кВт*год\n"
          "М.С. збитків від переривання: ${mznep.toStringAsFixed(2)} грн";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Надійність та збитки")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Завдання 1", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            buildGrid([
              buildInput("w_pl", cWpl),
              buildInput("t_pl", cTpl),
              buildInput("w_line", cWline),
              buildInput("t_line", cTline),
              buildInput("w_t", cWt),
              buildInput("t_t", cTt),
              buildInput("w_v", cWv),
              buildInput("t_v", cTv),
              buildInput("w_p", cWp),
              buildInput("t_p", cTp),
              buildInput("k_p_max", cKpMax),
              buildInput("w_cb", cWcb),
            ]),
            const SizedBox(height: 20),
            const Text("Завдання 2", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            buildGrid([
              buildInput("Z_nep_a", cZnepa),
              buildInput("Z_nep_p", cZnepp),
              buildInput("w_t_35", cWt35),
              buildInput("t_b_t_35", cTbt35),
              buildInput("P_m", cPm),
              buildInput("T_m", cTm),
              buildInput("k_p_t_35", cKpt35),
            ]),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculate,
              child: const Text("Розрахувати"),
            ),
            const SizedBox(height: 20),
            if (res1.isNotEmpty) buildResult("Результат Завдання 1", res1),
            if (res2.isNotEmpty) buildResult("Результат Завдання 2", res2),
          ],
        ),
      ),
    );
  }

  Widget buildGrid(List<Widget> children) {
    List<Widget> rows = [];
    for (int i = 0; i < children.length; i += 2) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(child: children[i]),
              const SizedBox(width: 10),
              Expanded(child: i + 1 < children.length ? children[i + 1] : const SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget buildInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget buildResult(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      color: Colors.green.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(content),
        ],
      ),
    );
  }
}