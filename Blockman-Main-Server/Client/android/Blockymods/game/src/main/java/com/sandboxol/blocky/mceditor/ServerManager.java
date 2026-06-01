package com.sandboxol.blocky.mceditor;

import android.os.Environment;

import com.sandboxol.common.base.app.BaseApplication;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by lenovo on 2015/4/17.
 */

public class ServerManager {
    public static void AddServer(String name, String ip, String port) {
        List<PEServer> serverList = new ArrayList<PEServer>();
        PEServer newServer = new PEServer();
        newServer.index = 1;
        newServer.name = name;
        newServer.ip = ip;
        newServer.port = port;

        ReadAllServer(serverList);
        for (int i = 0; i < serverList.size(); i++) {
            PEServer curServer = serverList.get(i);
            if (curServer.ip.equals(newServer.ip) && curServer.port.equals(newServer.port)) {
                serverList.remove(i);
                break;
            }
        }

        serverList.add(newServer);
        WriteAllServer(serverList);
    }

    public static void DeleteServer(String ip, String port) {
        List<PEServer> serverList = new ArrayList<PEServer>();
        ReadAllServer(serverList);

        boolean bFind = false;
        for (int i = 0; i < serverList.size(); i++) {
            if (serverList.get(i).ip.equals(ip) && serverList.get(i).port.equals(port)) {
                bFind = true;
                serverList.remove(i);
            }
        }

        if (bFind)
            WriteAllServer(serverList);
    }

    public static void DeleteServer(String ip) {
        List<PEServer> serverList = new ArrayList<PEServer>();
        ReadAllServer(serverList);

        boolean bFind = false;
        for (int i = 0; i < serverList.size(); i++) {
            if (serverList.get(i).ip.equals(ip)) {
                bFind = true;
                serverList.remove(i);
            }
        }

        if (bFind)
            WriteAllServer(serverList);
    }

    public static PEServer Parser(String strLine) {
        PEServer server = new PEServer();
        String[] array = strLine.split(":");
        server.index = Integer.parseInt(array[0]);
        server.name = array[1];
        server.ip = array[2];
        server.port = array[3];
        return server;
    }

    public static void DeleteAll() {

        File file = new File(Environment.getExternalStorageDirectory(), "games/com.mojang/minecraftpe/external_servers.txt");
        if (file.exists()) {
            file.delete();
        }
    }

    public static void ReadAllServer(List<PEServer> list) {

        File file = new File(Environment.getExternalStorageDirectory(), "games/com.mojang/minecraftpe/external_servers.txt");
        if (!file.exists()) {
            try {
                file.createNewFile();
                return;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new FileReader(file));
            String tempString = null;
            int line = 1;
            while ((tempString = reader.readLine()) != null) {
                line++;
                if (!tempString.isEmpty())
                    list.add(Parser(tempString));
            }
            reader.close();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (reader != null) {
                try {
                    reader.close();
                } catch (Exception e1) {
                }
            }
        }
    }

    public static void WriteAllServer(List<PEServer> list) {
        File appGames = new File("data/data/" + BaseApplication.getApp().getPackageName() + "/games/com.mojang/minecraftpe");
        if (!appGames.isDirectory()) {
            try {
                appGames.mkdirs();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        File serverFile = new File(Environment.getExternalStorageDirectory(), "games/com.mojang/minecraftpe/external_servers.txt");
        File appServerFile = new File("data/data/" + BaseApplication.getApp().getPackageName() + "/games/com.mojang/minecraftpe/external_servers.txt");

        if (serverFile.exists()) {
            serverFile.delete();
        }
        try {
            serverFile.createNewFile();
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (appServerFile.exists()) {
            appServerFile.delete();
        }

        try {
            appServerFile.createNewFile();
        } catch (Exception e) {
            e.printStackTrace();
        }

        BufferedWriter writer = null;
        try {
            writer = new BufferedWriter(new FileWriter(serverFile));
            for (int i = 0; i < list.size(); i++) {
                writer.newLine();
                PEServer server = list.get(i);
                String tempString = i + 1 + ":" + server.name + ":" + server.ip + ":" + server.port;
                writer.write(tempString);
            }
            writer.close();

            writer = new BufferedWriter(new FileWriter(appServerFile));
            for (int i = 0; i < list.size(); i++) {
                writer.newLine();
                PEServer server = list.get(i);
                String tempString = i + 1 + ":" + server.name + ":" + server.ip + ":" + server.port;
                writer.write(tempString);
            }
            writer.close();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (writer != null) {
                try {
                    writer.close();
                } catch (Exception e1) {
                }
            }
        }
    }
}
