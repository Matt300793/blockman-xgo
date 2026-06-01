
package com.sandboxol.mapeditor.view.activity.filechooser;

import android.app.ListActivity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.adapter.FileListAdapter;
import com.sandboxol.mapeditor.config.StringConstant;
import com.sandboxol.mapeditor.utils.FileUtils;
import com.sandboxol.mapeditor.utils.McUtils;

import java.io.File;
import java.io.FileFilter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import rx.Observable;

/**
 * @author paulburke (ipaulpro)
 */
public class FileChooserActivity extends ListActivity implements View.OnClickListener {

    public static final int RESULT_CODE_IMPORT_FIlES = 1001;
    public static final int RESULT_CODE_IMPORT_FIlE = 1002;
    public static final int RESULT_CODE_EXPORT = 1003;

    public static final int TYPE_FILES = 0;
    public static final int TYPE_FOLDER = 1;
    public static final int TYPE_FILE = 2;

    private static final boolean DEBUG = true;
    private static final String TAG = "FileChooserActivity";

    public static final int REQUEST_CODE = 6384;
    public static final String MIME_TYPE_ALL = "*/*";
    public static final String START_PATH = "start.path";
    public static final String CHOOSER_TYPE = "chooser.type";

    private static final String PATH = "image";
    private static final String POSITION = "position";
    private static final String HIDDEN_PREFIX = ".";

    private String path; // The current file image

    private File externalDir;
    private String mcPath;
    private ArrayList<File> files = new ArrayList<>();
    private List<File> selectFiles = new ArrayList<>();
    private Set<String> extendedMimeTypes = new HashSet<>();
    private int chooserType = TYPE_FILES;

    private Button btnConfirm;
    private TextView tvCurPath, tvBackLast;

    /**
     * File (not directories) filter.
     */
    private FileFilter fileFilter = file -> {
        final String fileName = file.getName();
        final String mimeType = FileUtils.getMimeType(FileChooserActivity.this, file);
        return file.isFile() && !fileName.startsWith(HIDDEN_PREFIX) &&
                (mimeType.equals(getIntent().getType()) || extendedMimeTypes.contains(mimeType));
    };

    /**
     * Folder (directories) filter.
     */
    private FileFilter dirFilter = file -> {
        final String fileName = file.getName();
        return file.isDirectory() && !fileName.startsWith(HIDDEN_PREFIX);
    };

    /**
     * File and folder comparator.
     * TODO Expose sorting option method
     */
    private Comparator<File> comparator = (f1, f2) -> f1.getName().toLowerCase().compareTo(f2.getName().toLowerCase());

    private Comparator<File> lastModifiedComparator = (f1, f2) -> {
        long a = f1.lastModified();
        long b = f2.lastModified();
        if (a == b) return 0;
        return a < b ? 1 : -1;
    };

    /**
     * External storage state broadcast receiver.
     */
    private BroadcastReceiver externalStorageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (DEBUG) Log.d(TAG, "External storage broadcast recieved: "
                    + intent.getData());
            updateExternalStorageState();
        }
    };


    /**
     * Activities extending FileChooserActivity must check against this, and implement
     * the associated Intent Filter in AndroidManifest.xml.
     *
     * @return True if the Intent Action is android.intent.action.GET_CONTENT.
     */
    protected boolean isIntentGetContent() {
        final Intent intent = getIntent();
        final String action = intent.getAction();
        if (DEBUG) Log.d(TAG, "Intent Action: " + action);
        return Intent.ACTION_GET_CONTENT.equals(action);
    }

    /**
     * Display the Intent Chooser.
     *
     * @param title Chooser Dialog title.
     * @param type  Explicit MIME data type filter.
     */
    protected void showFileChooser(String title, String type) {
        if (TextUtils.isEmpty(title)) title = getString(R.string.file_chooser_select_file);
        if (TextUtils.isEmpty(type)) type = MIME_TYPE_ALL;

        // Implicitly allow the user to select a particular kind of data
        final Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        // Specify the MIME data type filter (Must be lower case)
        intent.setType(type.toLowerCase());
        // Only return URIs that can be opened with ContentResolver
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        // Display intent chooser
        try {
            startActivityForResult(Intent.createChooser(intent, title), REQUEST_CODE);
        } catch (android.content.ActivityNotFoundException e) {
            onFileError(e);
        }
    }

    /**
     * Convenience method to show the File Chooser with the default
     * title and have it return all file types.
     */
    protected void showFileChooser() {
        showFileChooser(null, null);
    }

    /**
     * Fill the list with the current directory contents.
     */
    private void fillList(int position) {
        if (DEBUG) Log.d(TAG, "Current image: " + this.path);

        if (chooserType == TYPE_FILES || chooserType == TYPE_FILE) {
            tvCurPath.setText(R.string.file_chooser_select_import_path);
        } else {
            if (TextUtils.equals(mcPath, path)) {
                tvCurPath.setText(R.string.file_chooser_mc_path);
            } else {
                tvCurPath.setText(R.string.file_chooser_select_export_path);
            }
        }

        // Set the cuttent image as the Activity title
        setTitle(this.path);
        // Clear the list adapter
        ((FileListAdapter) getListAdapter()).clear();

        // Our current directory File instance
        final File pathDir = new File(path);

        // List file in this directory with the directory filter
        final File[] dirs = pathDir.listFiles(dirFilter);
        if (dirs != null) {
            // Sort the folders alphabetically
            Arrays.sort(dirs, comparator);
            // Add each folder to the File list for the list adapter
            Collections.addAll(files, dirs);
        }

        // List file in this directory with the file filter
        final File[] files = pathDir.listFiles(fileFilter);
        if (files != null) {
            // Sort the files alphabetically
            Arrays.sort(files, comparator);
            // Add each file to the File list for the list adapter
            Collections.addAll(this.files, files);
        }

        if (dirs == null && files == null) {
            if (DEBUG) Log.d(TAG, "Directory is empty");
        }

        // Assign the File list items as our adapter items
        ((FileListAdapter) getListAdapter()).setListItems(this.files);
        // Update the ListView
        ((FileListAdapter) getListAdapter()).notifyDataSetChanged();
        // Jump to the top of the list
        getListView().setSelection(position);
    }

    /**
     * Keep track of the directory hierarchy.
     *
     * @param add Add the current image to the directory stack.
     */
    private void updateBreadcrumb(boolean add) {
        if (add)
            return;
        if (this.externalDir.getAbsolutePath().equals(this.path)) {
            // If at the base directory, exit the Activity
            onFileSelectCancel();
            finish();
        } else {
            File parent = new File(path).getParentFile();
            if (parent.exists()) {
                this.path = parent.getPath();
                fillList(0);
            }
        }
    }

    /**
     * Update the external storage member variables.
     */
    private void updateExternalStorageState() {
        String state = Environment.getExternalStorageState();
        boolean writable;
        boolean available;
        if (Environment.MEDIA_MOUNTED.equals(state)) {
            available = writable = true;
        } else if (Environment.MEDIA_MOUNTED_READ_ONLY.equals(state)) {
            available = true;
            writable = false;
        } else {
            available = writable = false;
        }
        handleExternalStorageState(available, writable);
    }

    /**
     * Register the external storage BroadcastReceiver.
     */
    private void startWatchingExternalStorage() {
        IntentFilter filter = new IntentFilter();
        filter.addAction(Intent.ACTION_MEDIA_MOUNTED);
        filter.addAction(Intent.ACTION_MEDIA_REMOVED);
        registerReceiver(this.externalStorageReceiver, filter);
        if (isIntentGetContent())
            updateExternalStorageState();
    }

    /**
     * Unregister the external storage BroadcastReceiver.
     */
    private void stopWatchingExternalStorage() {
        unregisterReceiver(this.externalStorageReceiver);
    }

    /**
     * Respond to a change in the external storage state
     *
     * @param available
     * @param writable
     */
    private void handleExternalStorageState(boolean available, boolean writable) {
        if (!available && isIntentGetContent()) {
            if (DEBUG) Log.d(TAG, "External Storage was disconnected");
            onFileDisconnect();
            finish();
        }
    }

    /**
     * Called when a file is successfully selected by the user.
     *
     * @param file The file selected.
     */
    protected void onFileSelect(File file) {
        if (DEBUG) Log.d(TAG, "File selected: " + file.getAbsolutePath());
    }

    /**
     * Called when there is an error selecting a file.
     *
     * @param e The error encountered during file selection.
     */
    protected void onFileError(Exception e) {
        if (DEBUG) Log.e(TAG, "Error selecting file", e);
    }

    /**
     * Called when the user backs out of the file selection process.
     */
    protected void onFileSelectCancel() {
        if (DEBUG) Log.d(TAG, "File selection canceled");
    }

    /**
     * Called when the external storage (SD) is disconnected.
     */
    protected void onFileDisconnect() {
        if (DEBUG) Log.d(TAG, "External storage disconnected");
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_file_chooser);

        String[] extraMimeTypes = getIntent().getStringArrayExtra(FileUtils.EXTRA_MIME_TYPES);
        extendedMimeTypes.clear();
        if (extraMimeTypes != null) {
            Collections.addAll(extendedMimeTypes, extraMimeTypes);
        }

        // Get the external storage directory.
        this.externalDir = Environment.getExternalStorageDirectory();
        this.chooserType = getIntent().getIntExtra(CHOOSER_TYPE, TYPE_FILES);

        findViewById(R.id.ibBack).setOnClickListener(this);

        tvCurPath = findViewById(R.id.tvCurPath);

        tvBackLast = findViewById(R.id.tvBackLast);
        tvBackLast.setOnClickListener(this);

        btnConfirm = findViewById(R.id.btnConfirm);
        btnConfirm.setText(chooserType == TYPE_FILES ? R.string.my_map_import : R.string.my_map_export);
        btnConfirm.setOnClickListener(this);
        btnConfirm.setEnabled(chooserType != TYPE_FILES);

        mcPath = McUtils.getMcMapPath(this);

        if (chooserType == TYPE_FILE) {
            findViewById(R.id.flConfirm).setVisibility(View.GONE);
        }

        String sortMethod = getIntent().getStringExtra(FileUtils.EXTRA_SORT_METHOD);
        if (sortMethod != null) {
            if (sortMethod.equals(FileUtils.SORT_LAST_MODIFIED)) {
                this.comparator = this.lastModifiedComparator;
            }
        }

        if (getListAdapter() == null) {
            // Assign the list adapter to the ListView
            setListAdapter(new FileListAdapter(this, selectFiles, chooserType));
        }

        if (savedInstanceState != null) {
            restoreMe(savedInstanceState);
        } else {
            // Set the external storage directory as the current image
            this.path = this.externalDir.getAbsolutePath();
            String startPath = getIntent().getStringExtra(START_PATH);
            if (startPath != null) this.path = startPath;
            // Add the current image to the breadcrumb
            updateBreadcrumb(true);

            if (isIntentGetContent()) {

                fillList(0);
            }
        }

    }

    @Override
    protected void onResume() {
        super.onResume();
        startWatchingExternalStorage();
    }

    @Override
    protected void onStop() {
        super.onStop();
    }

    @Override
    protected void onPause() {
        super.onPause();
        stopWatchingExternalStorage();
    }

    @Override
    public void onBackPressed() {
        finish();
    }

    @Override
    protected void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);

        // Get the file that was selected from the file list
        File file = this.files.get(position);
        // Save the image as our current member variable
        this.path = file.getAbsolutePath();

        if (file.isDirectory()) {
            // If the selected item is a folder, update UI
            updateBreadcrumb(true);
            fillList(0);
        } else {
            if (chooserType == TYPE_FILE) {
                Intent data = new Intent();
                data.setData(Uri.parse(path));
                setResult(RESULT_CODE_IMPORT_FIlE, data);
                finish();
            } else {
                if (isSelected(file)) {
                    removeSelected(file);
                } else {
                    selectFiles.add(file);
                }
                btnConfirm.setEnabled(selectFiles.size() > 0 || chooserType == TYPE_FOLDER);
                ((FileListAdapter) getListAdapter()).notifyDataSetChanged();
            }
        }
    }

    private boolean isSelected(File file) {
        for (File item : selectFiles) {
            if (item.getPath().equals(file.getPath())) {
                return true;
            }
        }
        return false;
    }

    private void removeSelected(File file) {
        for (File item : selectFiles) {
            if (item.getPath().equals(file.getPath())) {
                selectFiles.remove(item);
                break;
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case REQUEST_CODE:
                if (resultCode == RESULT_OK) {
                    // If the file selection was successful
                    try {
                        // Get the URI of the selected file
                        Uri uri = data.getData();
                        // Create a file instance from the URI
                        String path = FileUtils.getPath(this, uri);
                        if (!TextUtils.isEmpty(path)) {
                            File file = new File(path);
                            onFileSelect(file);
                        }
                    } catch (Exception e) {
                        onFileError(e);
                    }
                } else if (resultCode == RESULT_CANCELED) {
                    onFileSelectCancel();
                }
                break;
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putString(PATH, path);
        outState.putInt(POSITION, getListView().getFirstVisiblePosition());
    }

    /**
     * If the activity was interrupted, restore the previous image and breadcrumb
     *
     * @param state
     */
    private void restoreMe(Bundle state) {
        this.path = (state.containsKey(PATH)) ?
                state.getString(PATH) : externalDir.getAbsolutePath();
        fillList(state.getInt(POSITION));
    }

    private ArrayList<Uri> getSelectedUri() {
        ArrayList<Uri> uris = new ArrayList<>();
        Observable.from(selectFiles).subscribe(file -> uris.add(Uri.fromFile(file)));
        return uris;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.ibBack:
                onBackPressed();
                break;
            case R.id.btnConfirm:
                onConfirm();
                break;
            case R.id.tvBackLast:
                updateBreadcrumb(false);
                break;
        }
    }

    private void onConfirm() {
        if (chooserType == TYPE_FILES) {
            Intent data = new Intent();
            data.putParcelableArrayListExtra(StringConstant.SELECTED_FILE_URI, getSelectedUri());
            setResult(RESULT_CODE_IMPORT_FIlES, data);
            finish();
        } else {
            Intent data = new Intent();
            data.setData(Uri.parse(path));
            setResult(RESULT_CODE_EXPORT, data);
            finish();
        }
    }

}
