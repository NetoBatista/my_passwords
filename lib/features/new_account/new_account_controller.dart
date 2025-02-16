import 'package:flutter/material.dart';
import 'package:password_manager/core/constant/local_storage_constant.dart';
import 'package:password_manager/core/constant/type_auth_constant.dart';
import 'package:password_manager/core/interface/ifirebase_service.dart';
import 'package:password_manager/core/interface/ilocal_storage_service.dart';
import 'package:password_manager/core/model/account_model.dart';
import 'package:password_manager/core/provider/dependency_provider.dart';
import 'package:password_manager/extension/navigation_extension.dart';
import 'package:password_manager/extension/translate_extension.dart';
import 'package:password_manager/shared/default_state_shared.dart';

class NewAccountController extends ValueNotifier<IDefaultStateShared> {
  NewAccountController() : super(DefaultStateShared());

  final IFirebaseService _firebaseService = DependencyProvider.get();
  final ILocalStorageService _localStorageService = DependencyProvider.get();

  void init() {
    value.error = '';
    value.isLoading = false;
    notifyListeners();
  }

  Future<void> submit(BuildContext context, AccountModel accountModel) async {
    try {
      value.error = '';
      value.isLoading = true;
      notifyListeners();

      var credential = await _firebaseService.createUserWithEmailAndPassword(
        accountModel.emailAddress,
        accountModel.password,
      );

      if (credential.user == null) {
        return;
      }

      await _localStorageService.setString(
        LocalStorageConstant.email,
        accountModel.emailAddress,
      );

      await _localStorageService.setString(
        LocalStorageConstant.typeAuth,
        TypeAuthConstant.emailPassword,
      );

      await _localStorageService.setString(
        LocalStorageConstant.password,
        accountModel.password,
      );

      if (!context.mounted) {
        return;
      }

      context.pushNamedAndRemoveUntil('/home');
    } catch (error) {
      value.error = 'error_default'.translate();
    } finally {
      value.isLoading = false;
      notifyListeners();
    }
  }
}
