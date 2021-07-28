import 'dart:ffi';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MaterialApp(
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
          onPanStart: (detalhes) {
            print(detalhes.localPosition);
            setState(() {
              if (_offsets.length < 4) {
                _offsets.add(detalhes.localPosition);
                print(_offsets.length);
              }
            });
          },
          onPanUpdate: (detalhes) {
            print(detalhes.globalPosition);
            setState(() {
              if (_offsets.length <= 4 && ultimoPonto == false) {
                _offsets[_offsets.length - 1] = detalhes.globalPosition;
              }
            });
          },
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
          child: Center(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.teal,
              child: CustomPaint(
                painter: MyPaint(_offsets, _offsetsInterpolacao,
                    MediaQuery.of(context).size),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            ultimoPonto = false;
                            _offsets.clear();
                            _offsetsInterpolacao.clear();
                          });
                        },
                        child: Text("Redesenhar"))
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

class MyPaint extends CustomPainter {
  final List<Offset> offset;
  final List<Offset> offsetInterpolacoes;
  final Size tamanhTela;
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
      canvas.drawLine(offset[0], offset[1], paintLinha);
      if (offset.length > 3) {
        canvas.drawLine(offset[2], offset[3], paintLinha);
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
      canvas.drawPoints(pointMode, offset, paintPonto);
      if (offset.length > 3) {
        canvas.drawLine(
            offsetInterpolacoes[0], offsetInterpolacoes[1], paintLinha);
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
      oX = -(offset[3].dy - offset[2].dy);
      oY = (offset[3].dx - offset[2].dx);
    }
    return [Offset(posx, posy), Offset(oX, oY)];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
