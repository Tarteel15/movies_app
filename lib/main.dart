import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/movies/presentation/bloc/browse_bloc.dart';
import 'features/movies/presentation/bloc/home_bloc.dart';
import 'features/movies/presentation/bloc/movie_details_bloc.dart';
import 'features/movies/presentation/bloc/search_bloc.dart';
import 'features/movies/presentation/pages/splash_page.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await di.initDependencies();

  runApp(const MoviesApp());
}

class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),

        BlocProvider<ProfileBloc>(create: (_) => di.sl<ProfileBloc>()),

        BlocProvider<HomeBloc>(create: (_) => di.sl<HomeBloc>()),

        BlocProvider<SearchBloc>(create: (_) => di.sl<SearchBloc>()),

        BlocProvider<BrowseBloc>(create: (_) => di.sl<BrowseBloc>()),

        BlocProvider<MovieDetailsBloc>(
          create: (_) => di.sl<MovieDetailsBloc>(),
        ),
      ],

      child: MaterialApp(
        title: 'Movies App',

        debugShowCheckedModeBanner: false,

        theme: AppTheme.darkTheme,

        home: const SplashPage(),
      ),
    );
  }
}
