import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);
}

final themeNotifier = ThemeNotifier();

class CalculadoraHomePage extends StatefulWidget {
  const CalculadoraHomePage({super.key});

  @override
  State<CalculadoraHomePage> createState() => CalculadoraHomePageState();
}

class CalculadoraHomePageState extends State<CalculadoraHomePage> {
  String display = '0';
  String historico = '';
  bool abreParenteses = true;
  int parentesesAbertos = 0;

  void atualizarDisplay(String valor) {
    setState(() {
      if (valor == '.' &&
          display.isNotEmpty &&
          display.split(RegExp(r'[+\-x/]')).last.contains('.')) {
        return;
      }

      if (RegExp(r'[+\-x/]').hasMatch(valor) &&
          display.isNotEmpty &&
          RegExp(r'[+\-x/]$').hasMatch(display)) {
        return;
      }

      if (display == '0' && RegExp(r'[x/]').hasMatch(valor)) {
        return;
      }
      if (display == '0' && valor != '.') {
        display = valor;
      } else {
        display += valor;
      }
    });
  }

  void aplicarPorcentagem() {
    try {
      final numero = double.parse(display);
      setState(() {
        display = (numero / 100).toString();
      });
    } catch (e) {
      mostrarErro("Número inválido para porcentagem.");
    }
  }

  void alternarSinal() {
    setState(() {
      if (display.startsWith('-')) {
        display = display.substring(1);
      } else if (display != '0') {
        display = '-$display';
      }
    });
  }

  void inserirParenteses() {
    setState(() {
      if (display == '0') display = '';
      if (abreParenteses) {
        if (display.isEmpty || RegExp(r'[+\-x/(]$').hasMatch(display)) {
          display += '(';
          parentesesAbertos++;
          abreParenteses = false;
        }
      } else if (parentesesAbertos > 0) {
        display += ')';
        parentesesAbertos--;
        abreParenteses = true;
      }
    });
  }

  void calcularResultado() {
    try {
      if (display.contains('/0') && !display.contains('/0.')) {
        mostrarErro("Divisão por zero não permitida.");
        return;
      }

      String expression = display;
      while (parentesesAbertos > 0) {
        expression += ')';
        parentesesAbertos--;
      }
      abreParenteses = true;
      final parser = Parser();
      final expr = parser.parse(expression.replaceAll('x', '*'));
      ContextModel cm = ContextModel();
      double eval = expr.evaluate(EvaluationType.REAL, cm);
      if (eval.isInfinite || eval.isNaN) {
        mostrarErro("Resultado inválido.");
        return;
      }
      setState(() {
        historico = display;
        display = eval.toStringAsFixed(2);
      });
    } catch (e) {
      mostrarErro("Expressão inválida.");
    }
  }

  void limparTudo() {
    setState(() {
      display = '0';
      historico = '';
      parentesesAbertos = 0;
      abreParenteses = true;
    });
  }

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  Widget botao(
    String texto, {
    Color? corTexto,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor:
            corTexto ?? Theme.of(context).textTheme.bodyLarge!.color,
        textStyle: const TextStyle(fontSize: 24),
      ),
      child: Text(texto),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
        actions: [
          IconButton(
            icon: Icon(
              themeNotifier.value == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              themeNotifier.value =
                  themeNotifier.value == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            color: Colors.orange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  display,
                  style: const TextStyle(fontSize: 48, color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  historico,
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "History",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(historico, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                botao('C', corTexto: Colors.red, onPressed: limparTudo),
                botao('()', onPressed: inserirParenteses),
                botao('%', onPressed: aplicarPorcentagem),
                botao('/', onPressed: () => atualizarDisplay('/')),
                botao('7', onPressed: () => atualizarDisplay('7')),
                botao('8', onPressed: () => atualizarDisplay('8')),
                botao('9', onPressed: () => atualizarDisplay('9')),
                botao('x', onPressed: () => atualizarDisplay('x')),
                botao('4', onPressed: () => atualizarDisplay('4')),
                botao('5', onPressed: () => atualizarDisplay('5')),
                botao('6', onPressed: () => atualizarDisplay('6')),
                botao('-', onPressed: () => atualizarDisplay('-')),
                botao('1', onPressed: () => atualizarDisplay('1')),
                botao('2', onPressed: () => atualizarDisplay('2')),
                botao('3', onPressed: () => atualizarDisplay('3')),
                botao('+', onPressed: () => atualizarDisplay('+')),
                botao('+/-', onPressed: alternarSinal),
                botao('0', onPressed: () => atualizarDisplay('0')),
                botao('.', onPressed: () => atualizarDisplay('.')),
                botao(
                  '=',
                  corTexto: Colors.green,
                  onPressed: calcularResultado,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
