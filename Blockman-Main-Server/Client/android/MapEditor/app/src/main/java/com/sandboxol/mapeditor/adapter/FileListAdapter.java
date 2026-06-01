/* 
 * Copyright (C) 2011 Paul Burke
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); 
 * you may not use this file except in compliance with the License. 
 * You may obtain a copy of the License at 
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0 
 * 
 * Unless required by applicable law or agreed to in writing, software 
 * distributed under the License is distributed on an "AS IS" BASIS, 
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
 * See the License for the specific language governing permissions and 
 * limitations under the License. 
 */

package com.sandboxol.mapeditor.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.TextView;

import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.view.activity.filechooser.FileChooserActivity;

import java.io.File;
import java.util.ArrayList;
import java.util.List;


/**
 * @author paulburke (ipaulpro)
 */
public class FileListAdapter extends BaseAdapter {

    private final static int ICON_FOLDER = R.mipmap.ic_folder;
    private final static int ICON_FILE = R.mipmap.ic_file;

    private ArrayList<File> files = new ArrayList<>();
    private LayoutInflater inflater;
    private List<File> selectFiles;
    private int type;

    public FileListAdapter(Context context, List<File> selectFiles, int type) {
        this.inflater = LayoutInflater.from(context);
        this.selectFiles = selectFiles;
        this.type = type;
    }

    public void setListItems(ArrayList<File> files) {
        this.files = files;
    }

    public int getCount() {
        return files.size();
    }

    public void add(File file) {
        files.add(file);
    }

    public void clear() {
        files.clear();
    }

    public Object getItem(int position) {
        return files.get(position);
    }

    public long getItemId(int position) {
        return position;
    }

    public View getView(int position, View convertView, ViewGroup parent) {
        View row = convertView;
        ViewHolder holder;
        if (row == null) {
            row = inflater.inflate(R.layout.item_file, parent, false);
            holder = new ViewHolder(row);
            row.setTag(holder);
        } else {
            holder = (ViewHolder) row.getTag();
        }
        final File file = (File) getItem(position);
        holder.tvFileName.setText(file.getName());
        holder.tvFileIcon.setImageResource(file.isDirectory() ? ICON_FOLDER : ICON_FILE);
        if (file.isDirectory() || type == FileChooserActivity.TYPE_FOLDER || type == FileChooserActivity.TYPE_FILE) {
            holder.cbState.setVisibility(View.GONE);
        } else {
            holder.cbState.setVisibility(View.VISIBLE);
            holder.cbState.setChecked(isSelected(file));
        }
        return row;
    }

    private boolean isSelected(File file) {
        for (File item : selectFiles) {
            if (item.getPath().equals(file.getPath())) {
                return true;
            }
        }
        return false;
    }

    private class ViewHolder {
        TextView tvFileName;
        ImageView tvFileIcon;
        CheckBox cbState;

        ViewHolder(View row) {
            tvFileName = row.findViewById(R.id.tvFileName);
            tvFileIcon = row.findViewById(R.id.tvFileIcon);
            cbState = row.findViewById(R.id.cbState);
        }
    }
}