
package com.sandboxol.mapeditor.entity;

import android.content.res.XmlResourceParser;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;
import org.xmlpull.v1.XmlPullParserFactory;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class MimeTypeParser {

	public static final String TAG_MIMETYPES = "MimeTypes";
	public static final String TAG_TYPE = "type";
	
	public static final String ATTR_EXTENSION = "extension";
	public static final String ATTR_MIMETYPE = "mimetype";
	
	private XmlPullParser xpp;
	private MimeTypes mimeTypes;
    
	public MimeTypeParser() {
	}
	
	public MimeTypes fromXml(InputStream in)
			throws XmlPullParserException, IOException {
		XmlPullParserFactory factory = XmlPullParserFactory.newInstance();

		xpp = factory.newPullParser();
		xpp.setInput(new InputStreamReader(in));

		return parse();
	}
	
	public MimeTypes fromXmlResource(XmlResourceParser in)
	throws XmlPullParserException, IOException {
		xpp = in;
		
		return parse();
	}

	public MimeTypes parse()
			throws XmlPullParserException, IOException {
		
		mimeTypes = new MimeTypes();
		
		int eventType = xpp.getEventType();

		while (eventType != XmlPullParser.END_DOCUMENT) {
			String tag = xpp.getName();

			if (eventType == XmlPullParser.START_TAG) {
				if (tag.equals(TAG_MIMETYPES)) {
					
				} else if (tag.equals(TAG_TYPE)) {
					addMimeTypeStart();
				}
			} else if (eventType == XmlPullParser.END_TAG) {
				if (tag.equals(TAG_MIMETYPES)) {
					
				}
			}

			eventType = xpp.next();
		}

		return mimeTypes;
	}
	
	private void addMimeTypeStart() {
		String extension = xpp.getAttributeValue(null, ATTR_EXTENSION);
		String mimetype = xpp.getAttributeValue(null, ATTR_MIMETYPE);
		
		mimeTypes.put(extension, mimetype);
	}
	
}
