package com.sandboxol.mapeditor.config;

import android.os.Environment;

import java.io.File;

/**
 * Created by Jimmy on 2017/11/28 0028.
 */
public interface FileConstant {

    String MY_MAP_DIR = Environment.getExternalStorageDirectory() + File.separator + "SandBoxOL/MapEditor/MyMaps";
    String MY_MAP_BACKUP_DIR = Environment.getExternalStorageDirectory() + File.separator + "SandBoxOL/MapEditor/BackupMaps";
    String MINECRAFT_MAP_DIR = Environment.getExternalStorageDirectory() + File.separator + "games/com.mojang/minecraftWorlds";
    String WY_MINECRAFT_MAP_DIR = Environment.getExternalStorageDirectory() + File.separator + "Android/data/%s/files/importWorlds";

    String TYPE_ZIP = "application/zip";

}
