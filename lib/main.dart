import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

void main() {
  ComponentExample001 myGame = ComponentExample001();
  runApp(
    GameWidget(
      game: myGame,
    ),
  );
}


// Simple component shape example of a square component
class Square extends PositionComponent with HasGameRef<ComponentExample001> {
  @override
  // TODO: implement gameRef
  ComponentExample001 get gameRef => super.gameRef;

  double health = 40;

  // default values
  //
  Vector2 velocity = Vector2(0, 1).normalized() * 50;
  var rotationSpeed = 0.3;
  var squareSize = 128.0;
  var color = Paint()
    ..color = Colors.orange
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  List<RectangleComponent> lifeBarElements = List<RectangleComponent>.filled(
      3, RectangleComponent(size: Vector2(1, 1)),
      growable: false);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    size.setValues(squareSize, squareSize);
    anchor = Anchor.center;
    createLifeBar();
  }

  @override
  //
  // render the shape
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), color);
  }

  @override
  //
  // update the inner state of the shape
  // in our case the position
  void update(double dt) {
    super.update(dt);
    // speed is refresh frequency independent
    position += velocity * dt;
    // add rotational speed update as well
    var angleDelta = dt * rotationSpeed;
    angle = (angle + angleDelta) % (2 * pi);

    if (health <= 0) {
      removeFromParent();
    }

    if (position.y > gameRef.size.y - size.y) {
      velocity.negate();
    }
    if (position.y < 0 + size.y) {
      velocity.negate();
    }

    createLifeBar();
  }

  //
  //
  // Create a rudimentary lifebar shape
  createLifeBar() {
    var lifeBarSize = Vector2(40, 10);
    var backgroundFillColor = Paint()
      ..color = Colors.grey.withOpacity(0.35)
      ..style = PaintingStyle.fill;
    var outlineColor = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    var lifeDangerColor = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // All positions here are in relation to the parent's position
    lifeBarElements = [
      //
      // The outline of the life bar
      RectangleComponent(
        position: Vector2(size.x - lifeBarSize.x, -lifeBarSize.y - 2),
        size: lifeBarSize,
        angle: 0,
        paint: outlineColor,
      ),
      //
      // The fill portion of the bar. The semi-transparent portion
      RectangleComponent(
        position: Vector2(size.x - lifeBarSize.x, -lifeBarSize.y - 2),
        size: lifeBarSize,
        angle: 0,
        paint: backgroundFillColor,
      ),
      //
      // The actual life percentage as a fill of red or green
      RectangleComponent(
        position: Vector2(size.x - lifeBarSize.x, -lifeBarSize.y - 2),
        size: Vector2((health / lifeBarSize.x) * lifeBarSize.x, 10),
        angle: 0,
        paint: lifeDangerColor,
      ),
    ];

    //
    // add all lifebar elements to the children of the Square instance
    addAll(lifeBarElements);
  }
}

// The game class
late Size screenSize;

class ComponentExample001 extends FlameGame
    with DoubleTapDetector, TapDetector {
  //

  // controls if the engine is paused or not
  bool running = true;
  @override
  // runnig in debug mode
  bool debugMode = false;

  //
  // text rendering const
  final TextPaint textPaint = TextPaint(
    style: const TextStyle(
      fontSize: 14.0,
      fontFamily: 'Awesome Font',
    ),
  );

  @override
  FutureOr<void> onLoad() {
    screenSize = size.toSize();
    print(screenSize);
  }

  @override
  //
  //
  // Process user's single tap (tap up)
  void onTapUp(TapUpInfo info) {
    // location of user's tap
    final touchPoint = info.eventPosition.global;
    print("<user tap> touchpoint: $touchPoint");

    //
    // handle the tap action
    //
    // check if the tap location is within any of the shapes on the screen
    // and if so remove the shape from the screen
    final handled = children.any((component) {
      if (component is Square && component.containsPoint(touchPoint)) {
        // remove(component);
        /// component.velocity.negate();
        component.health -= 5;
        return true;
      }
      return false;
    });

    //
    // this is a clean location with no shapes
    // create and add a new shape to the component tree under the FlameGame
    if (!handled) {
      add(Square()
        ..position = touchPoint
        ..squareSize = 45.0
        ..velocity = Vector2(0, 1).normalized() * 25
        ..color = (Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2));
    }
  }

  @override
  void onDoubleTap() {
    if (running) {
      pauseEngine();
    } else {
      resumeEngine();
    }

    running = !running;
  }

  @override
  void render(Canvas canvas) {
    textPaint.render(
        canvas,
        "Squares active: ${children.where((element) => element is Square).length}",
        Vector2(10, 20));
    super.render(canvas);
  }
}
