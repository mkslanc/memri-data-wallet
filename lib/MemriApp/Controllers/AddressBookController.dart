import 'package:flutter_contact/contacts.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemEdgeRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Model/Database.dart';
import 'package:moor/moor.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_number/phone_number.dart' as Phone;
import 'package:uuid/uuid.dart';

import 'FileStorageController_shared.dart';

class AddressBookController {
  static bool syncing = false;

  static sync() async {
    if (syncing != false) {
      return;
    }
    syncing = true;
    var contacts = await fetchContacts();
    await contacts?.forEach((contact) async {
      await upsertContact(contact);
    });
    syncing = false;
  }

  static Future<Stream<Contact>?> fetchContacts() async {
    if (await Permission.contacts.request().isGranted) {
      return Contacts.streamContacts();
    }
    return null;
  }

  static upsertContact(Contact contact) async {
    var db = AppController.shared.databaseController;
    var identifier =
        (contact.identifier != null) ? "AddressBook-" + contact.identifier! : "AddressBook-NaN";
    ItemRecord? existingContact = await personWithAddressBookID(identifier);
    if (existingContact == null) {
      var person = ItemRecord(type: "Person");
      await person.save(db.databasePool);
      await person.setPropertyValue("addressBookId", PropertyDatabaseValueString(identifier),
          db: db);
      existingContact = person;
    }
    var phoneNumbers = contact.phones;
    for (var phoneNumber in phoneNumbers) {
      try {
        Phone.PhoneNumber formattedPhone = await Phone.PhoneNumberUtil().parse(phoneNumber.value!);
        await savePhoneNumber(
            formattedPhoneNumber: formattedPhone.e164,
            person: existingContact,
            db: db.databasePool);
      } catch (e) {
        //TODO: what should we do with invalid phone numbers?
        print(e);
      }
    }

    for (var address in contact.postalAddresses) {
      await saveAddress(address: address, person: existingContact, db: db.databasePool);
    }

    if (contact.givenName != null) {
      await existingContact
          .setPropertyValue("firstName", PropertyDatabaseValueString(contact.givenName!), db: db);
    }
    if (contact.familyName != null) {
      await existingContact
          .setPropertyValue("lastName", PropertyDatabaseValueString(contact.familyName!), db: db);
    }
    if (contact.dates.isNotEmpty) {
      for (var date in contact.dates) {
        if (date.label == "birthday" &&
            date.date != null &&
            date.date!.isValid &&
            date.date!.year != null) {
          await existingContact.setPropertyValue(
              "birthDate",
              PropertyDatabaseValueDatetime(
                  DateTime(date.date!.year!, date.date!.month!, date.date!.day!)),
              db: db);
        }
      }
    }
    if (contact.emails.isNotEmpty) {
      //TODO: in android person could have few emails
      if (contact.emails[0].value != null) {
        await existingContact.setPropertyValue(
            "email", PropertyDatabaseValueString(contact.emails[0].value!),
            db: db);
      }
    }
    if (contact.hasAvatar) {
      await saveAvatar(avatar: contact.avatar!, person: existingContact, dbController: db);
    }
  }

  static Future<ItemRecord?> phoneNumberItemForPhoneNumber(
      {required String phoneNumber, required int phoneRowId, required Database db}) async {
    var phoneNumberItems = await db.itemPropertyRecordsCustomSelect(
        "name = ? AND value = ? AND item = ?",
        [Variable("phoneNumber"), Variable(phoneNumber), Variable(phoneRowId)]);
    if (phoneNumberItems.isEmpty) {
      return null;
    } else {
      return await ItemRecord.fetchWithRowID(phoneNumberItems[0].item);
    }
  }

  static Future<bool> hasSamePhoneNumber(
      {required String phoneNumber, required ItemRecord personItem, required Database db}) async {
    var phoneNumbers = await personItem.edgeItems("hasPhoneNumber");
    if (phoneNumbers.isNotEmpty) {
      for (var phone in phoneNumbers) {
        var foundPhone = await phoneNumberItemForPhoneNumber(
            phoneNumber: phoneNumber, phoneRowId: phone.rowId!, db: db);
        if (foundPhone != null) return true;
      }
    }
    return false;
  }

  static Future<ItemRecord?> getAddressItem(
      {required PostalAddress address, required int addressRowId, required Database db}) async {
    if (address.region != null) {
      var addressItems = await db.itemPropertyRecordsCustomSelect(
          "name = ? AND value = ? AND item = ?",
          [Variable("state"), Variable(address.region), Variable(addressRowId)]);
      if (addressItems.isEmpty) {
        return null;
      }
    }
    if (address.city != null) {
      var addressItems = await db.itemPropertyRecordsCustomSelect(
          "name = ? AND value = ? AND item = ?",
          [Variable("city"), Variable(address.city), Variable(addressRowId)]);
      if (addressItems.isEmpty) {
        return null;
      }
    }
    if (address.postcode != null) {
      var addressItems = await db.itemPropertyRecordsCustomSelect(
          "name = ? AND value = ? AND item = ?",
          [Variable("postalCode"), Variable(address.postcode), Variable(addressRowId)]);
      if (addressItems.isEmpty) {
        return null;
      }
    }
    if (address.street != null) {
      var addressItems = await db.itemPropertyRecordsCustomSelect(
          "name = ? AND value = ? AND item = ?",
          [Variable("street"), Variable(address.street), Variable(addressRowId)]);
      if (addressItems.isEmpty) {
        return null;
      } else {
        return await ItemRecord.fetchWithRowID(addressItems[0].item);
      }
    }
    return null;
  }

  static Future<bool> hasSameAddress(
      {required PostalAddress address,
      required ItemRecord personItem,
      required Database db}) async {
    var addresses = await personItem.edgeItems("address");
    if (addresses.isNotEmpty) {
      for (var addressItem in addresses) {
        var foundAddress =
            await getAddressItem(address: address, addressRowId: addressItem.rowId!, db: db);
        if (foundAddress != null) return true;
      }
    }
    return false;
  }

  static savePhoneNumber(
      {required String formattedPhoneNumber,
      required ItemRecord person,
      required Database db}) async {
    if (person.rowId != null) {
      if (await hasSamePhoneNumber(phoneNumber: formattedPhoneNumber, personItem: person, db: db) ==
          false) {
        var newPhoneItem = ItemRecord(type: "PhoneNumber");
        await newPhoneItem.save(db);
        await newPhoneItem.setPropertyValue(
            "phoneNumber", PropertyDatabaseValueString(formattedPhoneNumber));
        await ItemEdgeRecord(
                sourceRowID: person.rowId, name: "hasPhoneNumber", targetRowID: newPhoneItem.rowId)
            .save(db);
      }
    }
  }

  static saveAddress(
      {required PostalAddress address, required ItemRecord person, required Database db}) async {
    if (person.rowId != null) {
      if (await hasSameAddress(address: address, personItem: person, db: db) == false) {
        var newAddressItem = ItemRecord(type: "Address");
        await newAddressItem.save(db);
        if (address.city != null) {
          await newAddressItem.setPropertyValue("city", PropertyDatabaseValueString(address.city!));
        }
        if (address.region != null) {
          await newAddressItem.setPropertyValue(
              "state", PropertyDatabaseValueString(address.region!));
        }
        if (address.postcode != null) {
          await newAddressItem.setPropertyValue(
              "postalCode", PropertyDatabaseValueString(address.postcode!));
        }
        if (address.street != null) {
          await newAddressItem.setPropertyValue(
              "street", PropertyDatabaseValueString(address.street!));
        }
        await ItemEdgeRecord(
                sourceRowID: person.rowId, name: "address", targetRowID: newAddressItem.rowId)
            .save(db);
      }
    }
  }

  static saveAvatar(
      {required Uint8List avatar,
      required ItemRecord person,
      required DatabaseController dbController}) async {
    if (person.rowId != null) {
      var newImageItem = ItemRecord(type: "Photo");
      await newImageItem.save(dbController.databasePool);
      await ItemEdgeRecord(
              sourceRowID: person.rowId, name: "profilePicture", targetRowID: newImageItem.rowId)
          .save(dbController.databasePool);

      var newFileItem = ItemRecord(type: "File");
      await newFileItem.save(dbController.databasePool);

      try {
        var fileName = "${Uuid().v4()}.jpg";
        var url = (await FileStorageController.getFileStorageURL()) + "/" + fileName;
        await FileStorageController.write(url, avatar);
        var sha256 = await FileStorageController.getHashForFile(fileURL: url);
        await newFileItem.setPropertyValue("sha256", PropertyDatabaseValueString(sha256),
            db: dbController);
        await newFileItem.setPropertyValue("filename", PropertyDatabaseValueString(fileName),
            db: dbController);
      } catch (e) {
        print(e.toString());
      }
      await ItemEdgeRecord(
              sourceRowID: newImageItem.rowId, name: "file", targetRowID: newFileItem.rowId)
          .save(dbController.databasePool);
    }
  }

  static Future<ItemRecord?> personWithAddressBookID(String addressBookId, [Database? db]) async {
    db ??= AppController.shared.databaseController.databasePool;
    var addressBookReference = await db.itemPropertyRecordsCustomSelect(
        "name = ? AND value = ?", [Variable("addressBookId"), Variable(addressBookId)]);
    if (addressBookReference.isNotEmpty) {
      var person = await ItemRecord.fetchWithRowID(addressBookReference[0].item);
      if (person != null) {
        return person;
      }
    }
    return null;
  }
}
