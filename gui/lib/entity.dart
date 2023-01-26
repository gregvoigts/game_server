import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/frontend.dart';
import 'package:shared_models/shared_models.dart';

class EntityView extends StatelessWidget {
  final Entity? entity;
  final GameManager manager;
  const EntityView({super.key, this.entity, required this.manager});

  Color getColor() {
    if (entity != null) {
      var health = entity!.health * 1.0 / entity!.maxHealth;
      if (health < 0.3) {
        return Colors.redAccent.shade700;
      }
      if (health < 0.7) {
        return Colors.orange.shade700;
      }
    }
    return Colors.lightGreenAccent.shade400;
  }

  String getIdentifier() {
    if (entity == null) {
      return "";
    }
    if (entity.runtimeType == Monster) {
      return "M";
    }
    if (manager.isMe((entity as Player).playerId)) {
      return "U";
    }
    return "P";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          entity?.health.toString() ?? "",
          style: TextStyle(color: getColor(), fontSize: 10),
        ),
        Text(
          getIdentifier(),
          style: TextStyle(color: getColor(), fontSize: 10),
        )
      ],
    );
  }
}
