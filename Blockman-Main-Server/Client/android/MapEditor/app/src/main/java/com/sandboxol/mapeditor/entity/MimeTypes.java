
package com.sandboxol.mapeditor.entity;

import android.net.Uri;
import android.webkit.MimeTypeMap;

import com.sandboxol.mapeditor.utils.FileUtils;

import java.util.HashMap;
import java.util.Map;

public class MimeTypes {

	private Map<String, String> mimeTypes;

	public MimeTypes() {
		mimeTypes = new HashMap<>();
	}
	
	public void put(String type, String extension) {
		// Convert extensions to lower case letters for easier comparison
		extension = extension.toLowerCase();
		
		mimeTypes.put(type, extension);
	}
	
	public String getMimeType(String filename) {
		
		String extension = FileUtils.getExtension(filename);
		
		// Let's check the official map first. Webkit has a nice extension-to-MIME map.
		// Be sure to remove the first character from the extension, which is the "." character.
		if (extension.length() > 0) {
			String webkitMimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension.substring(1));
		
			if (webkitMimeType != null) {
				// Found one. Let's take it!
				return webkitMimeType;
			}
		}
		
		// Convert extensions to lower case letters for easier comparison
		extension = extension.toLowerCase();
		
		String mimetype = mimeTypes.get(extension);
		
		if(mimetype==null) mimetype = "*/*";
		
		return mimetype;
	}
	
	public String getMimeType(Uri uri) {
		return getMimeType(FileUtils.getFile(uri).getName());	
	}
	
}
