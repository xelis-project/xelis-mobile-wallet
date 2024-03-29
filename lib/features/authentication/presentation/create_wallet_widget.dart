import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:xelis_mobile_wallet/features/authentication/application/authentication_service.dart';
import 'package:xelis_mobile_wallet/features/authentication/application/open_wallet_state_provider.dart';
import 'package:xelis_mobile_wallet/features/router/route_utils.dart';
import 'package:xelis_mobile_wallet/features/settings/application/app_localizations_provider.dart';
import 'package:xelis_mobile_wallet/features/settings/application/theme_mode_state_provider.dart';
import 'package:xelis_mobile_wallet/features/wallet/presentation/wallet_tab/components/seed_on_creation_widget.dart';
import 'package:xelis_mobile_wallet/shared/theme/extensions.dart';
import 'package:xelis_mobile_wallet/shared/theme/constants.dart';
import 'package:xelis_mobile_wallet/shared/widgets/components/banner_widget.dart';
import 'package:xelis_mobile_wallet/features/router/login_action_codec.dart';

class CreateWalletWidget extends ConsumerStatefulWidget {
  const CreateWalletWidget({super.key});

  @override
  ConsumerState createState() => _CreateWalletWidgetState();
}

class _CreateWalletWidgetState extends ConsumerState<CreateWalletWidget> {
  final _createFormKey =
      GlobalKey<FormBuilderState>(debugLabel: '_createFormKey');

  bool _seedRequired = false;

  bool _hidePassword = true;

  late Widget _widgetCreation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initCreateButton();
  }

  void _initCreateButton() {
    final loc = ref.read(appLocalizationsProvider);
    _widgetCreation = SizedBox(
      width: 200,
      child: FilledButton(
        onPressed: _createWallet,
        child: Text(
          loc.create_wallet_button,
          style: context.titleMedium!.copyWith(color: context.colors.onPrimary),
        ),
      ),
    );
  }

  void _createWallet() {
    if (_createFormKey.currentState?.saveAndValidate() ?? false) {
      final loc = ref.read(appLocalizationsProvider);

      final walletName =
          _createFormKey.currentState?.value['wallet_name'] as String?;
      final password =
          _createFormKey.currentState?.value['password'] as String?;
      final seed = _createFormKey.currentState?.value['seed'] as String?;

      if (walletName != null && password != null) {
        setState(() {
          _widgetCreation = const CircularProgressIndicator();
        });

        ref
            .read(authenticationProvider.notifier)
            .createWallet(walletName, password, seed)
            .then((value) {
          setState(() {
            _widgetCreation = Column(
              children: [
                Icon(
                  Icons.check_rounded,
                  color: context.colors.primary,
                ),
                const SizedBox(height: Spaces.small),
                Text(
                  loc.create_wallet_message,
                  style: context.bodyMedium
                      ?.copyWith(color: context.colors.primary),
                ),
              ],
            );
          });
          if (seed == null) {
            _showSeed(password);
          }
        }, onError: (_) {
          setState(() {
            _initCreateButton();
          });
        });
      }
    }
  }

  void _showSeed(String password) {
    Timer.run(() => showDialog<void>(
        context: context,
        builder: (BuildContext context) => SeedOnCreationWidget(password)));
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(appLocalizationsProvider);

    final userThemeMode = ref.watch(userThemeModeProvider);
    final ScalableImageWidget banner =
        getBanner(context, userThemeMode.themeMode);

    final openWalletState = ref.watch(openWalletProvider);

    return FormBuilder(
      key: _createFormKey,
      onChanged: () => _createFormKey.currentState!.save(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spaces.large),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Row(
                      children: [
                        const Spacer(),
                        Hero(
                          tag: 'banner',
                          child: banner,
                        ),
                        const Spacer(),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      loc.create,
                      style: context.headlineLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          loc.already_wallet,
                          style: context.bodyLarge,
                        ),
                        TextButton(
                          onPressed: openWalletState.wallets.isNotEmpty
                              ? () {
                                  context.go(
                                    AppScreen.auth.toPath,
                                    extra: LoginAction.open,
                                  );
                                }
                              : null,
                          child: Text(loc.open_wallet_button),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spaces.small),
                    Theme(
                      data: context.theme.copyWith(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                      ),
                      child: FormBuilderSwitch(
                        name: 'seed_switch',
                        initialValue: _seedRequired,
                        title: Text(
                          loc.seed_option,
                          style: context.bodyLarge,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _seedRequired = value!;
                          });
                        },
                      ),
                    ),
                    Visibility(
                      visible: _seedRequired,
                      child: Column(
                        children: [
                          const SizedBox(height: Spaces.medium),
                          FormBuilderTextField(
                            name: 'seed',
                            style: context.bodyLarge,
                            autocorrect: false,
                            decoration: InputDecoration(
                              labelText: loc.seed,
                            ),
                            validator: FormBuilderValidators.compose([
                              // TODO: add better seed validator
                              FormBuilderValidators.match(
                                '(?:[a-zA-Z]+ ){24}[a-zA-Z]+',
                                errorText: loc.invalid_seed,
                              ),
                              // FormBuilderValidators.minWordsCount(25),
                              // FormBuilderValidators.maxWordsCount(25),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Spaces.medium),
                    FormBuilderTextField(
                      name: 'wallet_name',
                      style: context.bodyLarge,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: loc.wallet_name,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(1),
                        FormBuilderValidators.maxLength(64),
                        // check if this wallet name already exists.
                        (val) {
                          if (openWalletState.wallets.containsKey(val)) {
                            return loc.wallet_name_already_exists;
                          }
                          return null;
                        },
                      ]),
                    ),
                    const SizedBox(height: Spaces.medium),
                    FormBuilderTextField(
                      name: 'password',
                      style: context.bodyLarge,
                      autocorrect: false,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        labelText: loc.password,
                        suffixIcon: IconButton(
                          icon: _hidePassword
                              ? Icon(
                                  Icons.visibility_off_rounded,
                                  color: context.colors.secondary,
                                )
                              : Icon(
                                  Icons.visibility_rounded,
                                  color: context.colors.primary,
                                ),
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: Spaces.medium),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(Spaces.small),
                        child: AnimatedSwitcher(
                          duration: const Duration(
                              milliseconds: AppDurations.animFast),
                          child: _widgetCreation,
                        ),
                      ),
                    ),
                    const Spacer(
                      flex: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
