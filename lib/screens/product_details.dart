import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tienda_app/models/product_model.dart';
import 'package:tienda_app/providers/product_providers.dart';
import 'package:video_player/video_player.dart';

class RecipeDetails extends StatefulWidget {
  final ProductModel recipesData;

  const RecipeDetails({super.key, required this.recipesData});

  @override
  RecipeDetailsState createState() => RecipeDetailsState();
}

class RecipeDetailsState extends State<RecipeDetails> {
  bool isFavorite = false;
  bool cartAdded = false;
  int cantidad = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isFavorite = Provider.of<ProductProviders>(
      context,
      listen: false,
    ).favoriteRecipes.contains(widget.recipesData);

    cartAdded = Provider.of<ProductProviders>(
      context,
      listen: false,
    ).cartProducts.containsKey(widget.recipesData);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isInCart = Provider.of<ProductProviders>(
      context,
      listen: true, // para que se reconstruya cuando cambia
    ).cartProducts.containsKey(widget.recipesData);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: Text(
          "Detalles del producto",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [],
      ),

      body: Padding(
        padding: EdgeInsets.all(0),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipesData.name,
                    style: TextStyle(
                      fontFamily: 'Montserat',
                      fontSize: 20,
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () async {
                      await Provider.of<ProductProviders>(
                        context,
                        listen: false,
                      ).toggleFavoriteStatus(widget.recipesData);
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                    // icon: Icon(
                    //   isFavorite ? Icons.favorite : Icons.favorite_border,
                    //   color: Colors.white,
                    // ),
                    icon: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: colors.primary,
                        key: ValueKey<bool>(isFavorite),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              child: MediaCarousel(mediaUrls: widget.recipesData.mediaUrls),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "\$${(widget.recipesData.precio * 1.2).toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'QuickSand',
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "\$${widget.recipesData.precio.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 30,
                          fontFamily: 'QuickSand',
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    color: Theme.of(context).colorScheme.primary,
                    height: 3,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Acción
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.surface,
                        minimumSize: const Size.fromHeight(60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Comprar ahora!',
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final auth = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );

                        if (!auth.isAuthenticated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Inicia sesión para añadir al carrito",
                              ),
                            ),
                          );
                          return;
                        }
                        if (isInCart) {
                          // Si ya está en el carrito, eliminarlo directamente
                          Provider.of<ProductProviders>(
                            context,
                            listen: false,
                          ).toggleCartStatus(
                            widget.recipesData,
                            0,
                          ); // cantidad 0 o ignora la cantidad
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Producto eliminado del carrito"),
                            ),
                          );
                        } else {
                          // Si no está en el carrito, mostrar el modal para seleccionar cantidad
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder: (context) {
                              int cantidad = 1;
                              return StatefulBuilder(
                                builder:
                                    (context, setState) => Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Selecciona la cantidad',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  if (cantidad > 1) {
                                                    setState(() {
                                                      cantidad--;
                                                    });
                                                  }
                                                },
                                                icon: const Icon(Icons.remove),
                                              ),
                                              Text(
                                                '$cantidad',
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    cantidad++;
                                                  });
                                                },
                                                icon: const Icon(Icons.add),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          ElevatedButton(
                                            onPressed: () async {
                                              await Provider.of<
                                                ProductProviders
                                              >(
                                                context,
                                                listen: false,
                                              ).toggleCartStatus(
                                                widget.recipesData,
                                                cantidad,
                                              );
                                              Navigator.pop(
                                                context,
                                              ); // cerrar el modal
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Producto agregado al carrito",
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'Agregar al carrito',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              );
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        minimumSize: const Size.fromHeight(60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isInCart ? 'Eliminar del carrito' : 'Añadir al carrito',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),
                  Text("Descripcion:"),
                  Text(widget.recipesData.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaCarousel extends StatefulWidget {
  final List<String> mediaUrls;

  const MediaCarousel({super.key, required this.mediaUrls});

  @override
  // ignore: library_private_types_in_public_api
  _MediaCarouselState createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  final PageController _pageController = PageController();
  final List<VideoPlayerController?> _videoControllers = [];

  @override
  void initState() {
    super.initState();
    _initVideos();
  }

  void _initVideos() {
    for (var url in widget.mediaUrls) {
      if (url.endsWith('.mp4') ||
          url.endsWith('.webm') ||
          url.endsWith('.mov')) {
        // ignore: deprecated_member_use
        final controller = VideoPlayerController.network(url);
        controller
            .initialize()
            .then((_) {
              if (controller.value.isInitialized) {
                controller.setLooping(true);
                controller.play();
                setState(() {}); // actualiza UI cuando esté listo
              }
            })
            .catchError((e) {
              print("Error al inicializar video: $e");
            });
        _videoControllers.add(controller);
      } else {
        _videoControllers.add(null); // no es video
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller?.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // cuadrado
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.mediaUrls.length,
        itemBuilder: (context, index) {
          final url = widget.mediaUrls[index];
          final videoController = _videoControllers[index];

          if (videoController != null && videoController.value.isInitialized) {
            return VideoPlayer(videoController);
          } else if (videoController != null) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
                      Center(child: Text('Error cargando imagen $error')),
            );
          }
        },
      ),
    );
  }
}

// class RecipeDetails extends StatelessWidget {
//   final String recipeName;

//   const RecipeDetails({super.key, required this.recipeName});

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(recipeName),
//         leading: IconButton(
//           color: colors.primary,
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: Icon(Icons.arrow_back),
//         ),
//       ),
//     );
//   }
// }
