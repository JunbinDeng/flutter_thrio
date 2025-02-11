// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import 'package:flutter/widgets.dart';

import '../channel/thrio_channel.dart';
import '../module/thrio_module.dart';
import 'navigator_route_observer.dart';
import 'navigator_route_settings.dart';

typedef NavigatorRouteObserverCallback = void Function(
  NavigatorRouteObserver observer,
  RouteSettings settings,
);

class NavigatorRouteObserverChannel with NavigatorRouteObserver {
  NavigatorRouteObserverChannel(String entrypoint)
      : _channel = ThrioChannel(channel: '__thrio_route_channel__$entrypoint') {
    _on('didPush', (observer, routeSettings) {
      observer.didPush(routeSettings);
    });
    _on('didPop', (observer, routeSettings) {
      observer.didPop(routeSettings);
    });
    _on('didPopTo', (observer, routeSettings) {
      observer.didPopTo(routeSettings);
    });
    _on('didRemove', (observer, routeSettings) {
      observer.didRemove(routeSettings);
    });
  }

  final ThrioChannel _channel;

  @override
  void didPush(RouteSettings routeSettings) => _channel.invokeMethod<bool>(
        'didPush',
        routeSettings.toArguments()..remove('params'),
      );

  @override
  void didPop(RouteSettings routeSettings) => _channel.invokeMethod<bool>(
        'didPop',
        routeSettings.toArguments()..remove('params'),
      );

  @override
  void didPopTo(RouteSettings routeSettings) => _channel.invokeMethod<bool>(
        'didPopTo',
        routeSettings.toArguments()..remove('params'),
      );

  @override
  void didRemove(RouteSettings routeSettings) => _channel.invokeMethod<bool>(
        'didRemove',
        routeSettings.toArguments()..remove('params'),
      );

  void _on(String method, NavigatorRouteObserverCallback callback) =>
      _channel.registryMethodCall(method, ([arguments]) {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        if (routeSettings != null) {
          final observers =
              ThrioModule.gets<NavigatorRouteObserver>(url: routeSettings.url);
          for (final observer in observers) {
            callback(observer, routeSettings);
          }
        }
        return Future.value();
      });
}
