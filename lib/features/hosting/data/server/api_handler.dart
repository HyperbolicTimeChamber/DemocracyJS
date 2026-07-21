import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';

class ApiHandler {
  ApiHandler({
    required this.getPoll,
    required this.onVote,
    required this.getClientCount,
  });

  final Poll Function() getPoll;
  final Future<bool> Function(List<String> optionIds, String ip) onVote;
  final int Function() getClientCount;

  Router get router {
    final r = Router();

    r.get('/api/poll', _handleGetPoll);
    r.get('/api/results', _handleGetResults);
    r.get('/api/status', _handleGetStatus);
    r.post('/api/vote', _handleVote);

    return r;
  }

  Response _handleGetPoll(Request request) {
    final poll = getPoll();
    final body = {
      'id': poll.id,
      'question': poll.question,
      'options': poll.options
          .map((o) => {'id': o.id, 'text': o.text})
          .toList(),
      'voteMode': poll.voteMode.toJson(),
      'resultsVisibility': poll.resultsVisibility.toJson(),
    };
    return Response.ok(
      jsonEncode(body),
      headers: _jsonHeaders,
    );
  }

  Response _handleGetResults(Request request) {
    final poll = getPoll();
    final totalVotes =
        poll.options.fold<int>(0, (sum, o) => sum + o.voteCount);
    final body = {
      'options': poll.options
          .map((o) =>
              {'id': o.id, 'text': o.text, 'voteCount': o.voteCount})
          .toList(),
      'totalVotes': totalVotes,
      'visibility': poll.resultsVisibility.toJson(),
    };
    return Response.ok(
      jsonEncode(body),
      headers: _jsonHeaders,
    );
  }

  Response _handleGetStatus(Request request) {
    return Response.ok(
      jsonEncode({
        'status': 'running',
        'connectedClients': getClientCount(),
      }),
      headers: _jsonHeaders,
    );
  }

  Future<Response> _handleVote(Request request) async {
    try {
      final body =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final optionIds = (body['optionIds'] as List).cast<String>();

      final connectionInfo = request.context['shelf.io.connection_info'];
      final ip = connectionInfo != null
          ? (connectionInfo as dynamic).remoteAddress.address as String
          : request.headers['x-forwarded-for'] ?? 'unknown';

      final success = await onVote(optionIds, ip);

      if (!success) {
        return Response.ok(
          jsonEncode({'error': 'already_voted'}),
          headers: _jsonHeaders,
        );
      }

      return Response.ok(
        jsonEncode({'success': true}),
        headers: _jsonHeaders,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: _jsonHeaders,
      );
    }
  }

  static const _jsonHeaders = {
    'content-type': 'application/json',
    'access-control-allow-origin': '*',
    'access-control-allow-methods': 'GET, POST, OPTIONS',
    'access-control-allow-headers': 'content-type',
  };
}
