import 'package:bloc_clean_arch_flutter/features/login/domain/entities/user.dart';
import 'package:bloc_clean_arch_flutter/features/login/presentation/bloc/auth_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Landing screen after login. Reads the user from the app-wide
/// [AuthBloc] — it owns no bloc of its own.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // `select` rebuilds only when the user changes, not on every state.
    final user = context.select((AuthBloc bloc) => bloc.state.user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            // No navigation here: the router sends us to login once the
            // auth state flips to unauthenticated.
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
      // Null only for the instant between logout and the redirect.
      body: user == null ? const SizedBox.shrink() : _Profile(user: user),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(child: _Avatar(user: user)),
        const SizedBox(height: 16),
        Text(
          'Welcome, ${user.name}!',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        _InfoTile(icon: Icons.phone, label: 'Mobile', value: user.mobile),
        _InfoTile(icon: Icons.email, label: 'Email', value: user.email),
        _InfoTile(
          icon: Icons.work,
          label: 'Profession',
          value: user.profession,
        ),
        _InfoTile(
          icon: Icons.school,
          label: 'Institution',
          value: user.institution,
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final User user;

  static const _radius = 48.0;

  @override
  Widget build(BuildContext context) {
    final initial = Text(
      user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
      style: Theme.of(context).textTheme.headlineMedium,
    );

    if (!user.hasPhoto) {
      return CircleAvatar(radius: _radius, child: initial);
    }

    return CachedNetworkImage(
      imageUrl: user.photo!,
      imageBuilder: (context, image) =>
          CircleAvatar(radius: _radius, backgroundImage: image),
      placeholder: (context, url) => const CircleAvatar(
        radius: _radius,
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) =>
          CircleAvatar(radius: _radius, child: initial),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, this.value});

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
