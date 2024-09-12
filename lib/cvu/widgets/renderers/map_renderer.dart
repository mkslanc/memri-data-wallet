/*
import 'package:flutter/material.dart';
import 'package:memri/cvu/widgets/renderers/renderer.dart';

import '../../../core/models/item.dart';
import '../../../widgets/components/map/map_view.dart';
import '../components/elements/cvu_map.dart';


/// The map renderer
/// This presents the data items on a map
/// - for an item to be shown the CVU for ItemType > map {...} must define an expression resolving to either a `Location` or `Address` item
/// - you can provide a `label` property in the CVU for ItemType > map {...}
class MapRendererView extends Renderer {
  MapRendererView({required viewContext}) : super(viewContext: viewContext);

  @override
  _MapRendererViewState createState() => _MapRendererViewState();
}

class _MapRendererViewState extends RendererViewState {
  @override
  Widget build(BuildContext context) {
    return MapViewWidget(config: mapConfig);
  }

 List<Item> Function(Item) get locationResolver {
    return (Item item)  =>
        widget.viewContext.nodePropertyResolver(item)?.items("location") ?? [];
  }

  List<Item> Function(Item) get addressResolver {
    return (Item item) =>
        widget.viewContext.nodePropertyResolver(item)?.items("address") ?? [];
  }

  String? Function(Item) get labelResolver {
    return (Item item) => widget.viewContext.nodePropertyResolver(item)?.string("label");
  }

  MapViewConfig get mapConfig {
    var resolver = widget.viewContext.rendererDefinitionPropertyResolver;
    var moveable = resolver.boolean("moveable", true);

    return MapViewConfig(
        dataItems: widget.viewContext.items,
        locationResolver: locationResolver,
        addressResolver: addressResolver,
        labelResolver: labelResolver,
        moveable: moveable);
  }
}
*/
