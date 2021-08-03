import 'dart:ffi';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Pintura(),
  ));
}

class Pintura extends StatefulWidget {
  const Pintura({Key key}) : super(key: key);

  @override
  _PinturaState createState() => _PinturaState();
}

class _PinturaState extends State<Pintura> {
  final _offsets = <Offset>[];
  final _offsetsInterpolacao = <Offset>[];
  bool ultimoPonto = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        // essa função pega a posição atual e adiciona na lista "vetores"
        onPanStart: (detalhes) {
          setState(() {
            if (_offsets.length < 4) {
              _offsets.add(Offset(
                  detalhes.globalPosition.dx -
                      MediaQuery.of(context).size.width / 2,
                  MediaQuery.of(context).size.height / 2 -
                      detalhes.globalPosition.dy));
            }
          });
        },
        //essa função atualiza a posição atual do ponto quando arrasta o dedo na tela
        onPanUpdate: (detalhes) {
          print(detalhes.globalPosition);
          setState(() {
            if (_offsets.length <= 4 && ultimoPonto == false) {
              _offsets[_offsets.length - 1] = Offset(
                  detalhes.globalPosition.dx -
                      MediaQuery.of(context).size.width / 2,
                  MediaQuery.of(context).size.height / 2 -
                      detalhes.globalPosition.dy);
            }
          });
        },
        //se for o ultimo ponto, então quando soltar o dedo não pode mais alterar a posição
        onPanEnd: (detalhes) {
          setState(() {
            if (_offsets.length == 4) {
              ultimoPonto = true;
            }
          });
        },
        /*
        ,
        onPanEnd: (detalhes) {
          print(detalhes);
          _offsets.add(null);
        },
        */
        child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.teal,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.asset(
                  'assets/escoliose.jpg',
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.cover,
                ),
                //Esse widget e que serve para criar os desenhos, mais detalhes na classe Mypaint que criei embaixo
                CustomPaint(
                  painter: MyPaint(_offsets, _offsetsInterpolacao,
                      MediaQuery.of(context).size),
                ),
                Positioned(
                    bottom: 0,
                    child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            ultimoPonto = false;
                            _offsets.clear();
                            _offsetsInterpolacao.clear();
                            MyPaint.resultado = 0;
                          });
                        },
                        child: Text("Redesenhar"))),
                Positioned(
                    top: 70,
                    left: 20,
                    child: MyPaint.resultado != 0
                        ? Text(
                            "Angulo: ${MyPaint.resultado.toStringAsFixed(2)} graus",
                            style: TextStyle(color: Colors.white, fontSize: 20))
                        : Text(
                            "Aguardando cálculo",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ))
              ],
            )),
      ),
    );
  }
}

//classe que serve para desenhar a tela
class MyPaint extends CustomPainter {
  final List<Offset> offset;
  final List<Offset> offsetInterpolacoes;
  final Size tamanhTela;
  static double resultado = 0;
  bool limiteInterpolacao = false;

  MyPaint(this.offset, this.offsetInterpolacoes, this.tamanhTela);

  final pointMode = PointMode.points;

  @override
  void paint(Canvas canvas, Size size) {
    //offsetInterpolacoes.add(Offset.zero);
    // TODO: implement paint
    final paintPonto = Paint()
      ..color = Colors.black
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final paintLinha = Paint()
      ..color = Colors.black
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    if (offset.length >= 2) {
      canvas.drawLine(
          Offset(offset[0].dx + tamanhTela.width / 2,
              tamanhTela.height / 2 - offset[0].dy),
          Offset(offset[1].dx + tamanhTela.width / 2,
              tamanhTela.height / 2 - offset[1].dy),
          paintLinha);
      if (offset.length > 3) {
        canvas.drawLine(
            Offset(offset[2].dx + tamanhTela.width / 2,
                tamanhTela.height / 2 - offset[2].dy),
            Offset(offset[3].dx + tamanhTela.width / 2,
                tamanhTela.height / 2 - offset[3].dy),
            paintLinha);
        if (offsetInterpolacoes.length < 4) {
          offsetInterpolacoes.add(interpolacaoV1()[0]);
          offsetInterpolacoes.add(interpolacaoV1()[1]);
          offsetInterpolacoes.add(interpolacaoV2()[0]);
          offsetInterpolacoes.add(interpolacaoV2()[1]);
        }
        print(offsetInterpolacoes.length);
      }
    }
    if (offset.length > 0 && offset.length <= 4) {
      List<Offset> pontos = <Offset>[];
      for (var item in offset) {
        pontos.add(Offset(
            item.dx + tamanhTela.width / 2, tamanhTela.height / 2 - item.dy));
      }
      canvas.drawPoints(pointMode, pontos, paintPonto);
      if (offset.length > 3) {
        var plano1 = interpolacaoV1()[0];
        var perp1 = interpolacaoV1()[1];
        var plano2 = interpolacaoV2()[0];
        var perp2 = interpolacaoV2()[1];
        var intersec = intersect2D(plano1, perp1, plano2, perp2);
        canvas.drawLine(
            Offset(tamanhTela.width / 2 + offsetInterpolacoes[0].dx,
                tamanhTela.height / 2 - offsetInterpolacoes[0].dy),
            Offset(offsetInterpolacoes[1].dx + tamanhTela.width / 2,
                tamanhTela.height / 2 - offsetInterpolacoes[1].dy),
            paintLinha);
        canvas.drawLine(
            Offset(tamanhTela.width / 2 + offsetInterpolacoes[2].dx,
                tamanhTela.height / 2 - offsetInterpolacoes[2].dy),
            Offset(offsetInterpolacoes[3].dx + tamanhTela.width / 2,
                tamanhTela.height / 2 - offsetInterpolacoes[3].dy),
            paintLinha);
        var produtoEscalar =
            ((perp1.dx - intersec.dx) * (plano2.dx - intersec.dx) +
                ((perp1.dy - intersec.dy) * (plano2.dy - intersec.dy)));
        var modulos = sqrt(pow(perp1.dx - intersec.dx, 2) +
                pow(perp1.dy - intersec.dy, 2)) *
            sqrt(pow(plano2.dx - intersec.dx, 2) +
                pow(plano2.dy - intersec.dy, 2));
        var escalarDivModulo = produtoEscalar / modulos;
        var angulo = acos(escalarDivModulo);
        angulo = (180 * angulo) / pi;
        resultado = angulo;
        print(angulo.toStringAsFixed(2) + " Graus");
      }
    }
  }

  List<Offset> interpolacaoV1() {
    double posx;
    double posy;
    double oX;
    double oY;
    if (offset.length >= 2) {
      posx = offset[0].dx + (0.5 * (offset[1].dx - offset[0].dx));
      posy = offset[0].dy + (0.5 * (offset[1].dy - offset[0].dy));
      oX = -(offset[1].dy - offset[0].dy);
      oY = (offset[1].dx - offset[0].dx);
    }
    return [Offset(posx, posy), Offset(oX, oY)];
  }

  List<Offset> interpolacaoV2() {
    double posx;
    double posy;
    double oX;
    double oY;
    if (offset.length > 3) {
      posx = offset[2].dx + (0.5 * (offset[3].dx - offset[2].dx));
      posy = offset[2].dy + (0.5 * (offset[3].dy - offset[2].dy));
      oX = (offset[3].dy - offset[2].dy);
      oY = -(offset[3].dx - offset[2].dx);
    }
    return [Offset(posx, posy), Offset(oX, oY)];
  }

  //função que faz o calculo de intersecção entre as duas retas
  Offset intersect2D(Offset inicioReta1, Offset finalReta1, Offset inicioReta2,
      Offset finalReta2) {
    double det;
    double s;
    double t;
    Offset Inters = Offset(0, 0);

    det = (finalReta2.dx - inicioReta2.dx) * (finalReta1.dy - inicioReta1.dy) -
        (finalReta2.dy - inicioReta2.dy) * (finalReta1.dx - inicioReta1.dx);

    s = ((finalReta2.dx - inicioReta2.dx) * (inicioReta2.dy - inicioReta1.dy) -
            (finalReta2.dy - inicioReta2.dy) *
                (inicioReta2.dx - inicioReta1.dx)) /
        det;
    t = ((finalReta1.dx - inicioReta1.dx) * (inicioReta2.dy - inicioReta1.dy) -
            (finalReta1.dy - inicioReta1.dy) *
                (inicioReta2.dx - inicioReta1.dx)) /
        det;

    Inters = Offset(inicioReta1.dx + (finalReta1.dx - inicioReta1.dx) * s,
        inicioReta1.dy + (finalReta1.dy - inicioReta1.dy) * s);

    return Inters;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
