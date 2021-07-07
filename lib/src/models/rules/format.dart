import '../documents/attribute.dart';
import '../quill_delta.dart';
import 'rule.dart';

abstract class FormatRule extends Rule {
  const FormatRule();

  @override
  RuleType get type => RuleType.FORMAT;

  @override
  void validateArgs(int? len, Object? data, Attribute? attribute) {
    assert(len != null);
    assert(data == null);
    assert(attribute != null);
  }
}

class ResolveLineFormatRule extends FormatRule {
  const ResolveLineFormatRule();

  @override
  Delta? applyRule(Delta document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    if (attribute!.scope != AttributeScope.BLOCK) {
      return null;
    }

    var delta = Delta()..retain(index);
    final itr = DeltaIterator(document)..skip(index);
    Operation op;
    for (var cur = 0; cur < len! && itr.hasNext; cur += op.length!) {
      op = itr.next(len - cur);
      if (op.data is! String || !(op.data as String).contains('\n')) {
        delta.retain(op.length!);
        continue;
      }
      final text = op.data as String;
      final tmp = Delta();
      var offset = 0;

      for (var lineBreak = text.indexOf('\n');
          lineBreak >= 0;
          lineBreak = text.indexOf('\n', offset)) {
        tmp..retain(lineBreak - offset)..retain(1, attribute.toJson());
        offset = lineBreak + 1;
      }
      tmp.retain(text.length - offset);
      delta = delta.concat(tmp);
    }

    while (itr.hasNext) {
      op = itr.next();
      final text = op.data is String ? (op.data as String?)! : '';
      final lineBreak = text.indexOf('\n');
      if (lineBreak < 0) {
        delta.retain(op.length!);
        continue;
      }
      delta..retain(lineBreak)..retain(1, attribute.toJson());
      break;
    }
    return delta;
  }
}

class FormatLinkAtCaretPositionRule extends FormatRule {
  const FormatLinkAtCaretPositionRule();

  @override
  Delta? applyRule(Delta document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    if (attribute!.key != Attribute.link.key || len! > 0) {
      return null;
    }

    final delta = Delta();
    final itr = DeltaIterator(document);
    final before = itr.skip(index), after = itr.next();
    int? beg = index, retain = 0;
    if (before != null && before.hasAttribute(attribute.key)) {
      beg -= before.length!;
      retain = before.length;
    }
    if (after.hasAttribute(attribute.key)) {
      if (retain != null) retain += after.length!;
    }
    if (retain == 0) {
      return null;
    }

    delta..retain(beg)..retain(retain!, attribute.toJson());
    return delta;
  }
}

class ResolveInlineFormatRule extends FormatRule {
  const ResolveInlineFormatRule();

  @override
  Delta? applyRule(Delta document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    if (attribute!.scope != AttributeScope.INLINE) {
      return null;
    }

    final delta = Delta()..retain(index);
    final itr = DeltaIterator(document)..skip(index);

    Operation op;
    for (var cur = 0; cur < len! && itr.hasNext; cur += op.length!) {
      op = itr.next(len - cur);
      var cond = true;
      var isHashtagOrMentionOrLink = false;

      print('attributes --> ${op.attributes}');
      print('data --> ${op.data}');
      print('length --> ${op.length}');

      isHashtagOrMentionOrLink = op.attributes != null &&
          op.attributes!.isNotEmpty &&
          op.attributes!.containsKey(Attribute.hashtag.key) &&
          op.attributes!.containsKey(Attribute.mention.key) &&
          op.attributes!.containsKey(Attribute.link.key);

      /*final isNewHashtagOrMentionOrLink = op.attributes != null &&
              op.attributes!.isNotEmpty &&
              (op.attributes!.containsKey(Attribute.hashtag.key) &&
                  attribute.key == Attribute.hashtag.key) ||
          (op.attributes!.containsKey(Attribute.mention.key) &&
              attribute.key == Attribute.mention.key) ||
          (op.attributes!.containsKey(Attribute.link.key) &&
              attribute.key == Attribute.link.key);*/

      cond = op.attributes == null ||
          op.attributes!.isEmpty ||
          (!op.attributes!.containsKey(Attribute.hashtag.key) &&
              !op.attributes!.containsKey(Attribute.mention.key) &&
              !op.attributes!.containsKey(Attribute.link.key)) ||
          ((op.attributes!.containsKey(Attribute.hashtag.key) &&
                  attribute.key == Attribute.hashtag.key) ||
              (op.attributes!.containsKey(Attribute.mention.key) &&
                  attribute.key == Attribute.mention.key) ||
              (op.attributes!.containsKey(Attribute.link.key) &&
                  attribute.key == Attribute.link.key));

      print('isHashtagOrMentionOrLink --> $isHashtagOrMentionOrLink');
      print('cond --> $cond');
      print('___________________');

      final text = op.data is String ? (op.data as String?)! : '';
      var lineBreak = text.indexOf('\n');
      if (!cond) {
        delta.retain(op.length!);
        continue;
      } else if (isHashtagOrMentionOrLink) {
        delta
          ..delete(op.length!)
          ..insert(op.data, attribute.toJson());
        continue;
      } else if (lineBreak < 0) {
        delta.retain(op.length!, attribute.toJson());
        continue;
      }
      var pos = 0;
      while (lineBreak >= 0) {
        delta..retain(lineBreak - pos, attribute.toJson())..retain(1);
        pos = lineBreak + 1;
        lineBreak = text.indexOf('\n', pos);
      }
      if (pos < op.length! && cond) {
        delta.retain(op.length! - pos, attribute.toJson());
      }
    }

    return delta;
  }
}
