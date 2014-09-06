package ${contentProvider.javaPackage};

import android.content.ContentProvider;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.UriMatcher;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteQueryBuilder;
import android.net.Uri;

import de.greenrobot.dao.DaoLog;

<#--
##########################################
########## java包引入 ##############
##########################################
-->
import ${schema.defaultJavaPackageDao}.DaoSession;
import ${entity.javaPackageDao}.${entity.classNameDao};

/* Copy this code snippet into your AndroidManifest.xml inside the
   <application> element:

<provider
android:name="${contentProvider.javaPackage}.${contentProvider.className}"
android:authorities="${contentProvider.authority}"/>
 */

<#--
##########################################
########## 类名 ##############
##########################################
-->
public class ${contentProvider.className} extends ContentProvider {

	##########################################
	########## CONTENT_URI ##############
	##########################################
	public static final String AUTHORITY = "${contentProvider.authority}";
	public static final String BASE_PATH = "${contentProvider.basePath}";
	public static final Uri CONTENT_URI = Uri.parse("content://" + AUTHORITY + "/" + BASE_PATH);
<#--
##########################################
########## 地址匹配 ##############
##########################################
-->
	public static final String CONTENT_TYPE = ContentResolver.CURSOR_DIR_BASE_TYPE
		+ "/" + BASE_PATH;
	public static final String CONTENT_ITEM_TYPE = ContentResolver.CURSOR_ITEM_BASE_TYPE
		+ "/" + BASE_PATH;

	/*private static final String TABLENAME = ${entity.classNameDao}.TABLENAME;
	private static final String PK = ${entity.classNameDao}.Properties.${entity.pkProperty.propertyName?cap_first}
	.columnName;*/

<#assign counter = 0>
<#list contentProvider.entities as entity>
	private static final int ${entity.className?upper_case}_DIR = ${counter};
	private static final int ${entity.className?upper_case}_ID = ${counter+1};
<#assign counter = counter + 2>  
</#list>

	private static final UriMatcher sURIMatcher;

	static {
		sURIMatcher = new UriMatcher(UriMatcher.NO_MATCH);
<#list contentProvider.entities as entity>
		sURIMatcher.addURI(AUTHORITY, BASE_PATH, ${entity.className?upper_case}_DIR);
		sURIMatcher.addURI(AUTHORITY, BASE_PATH + "/#", ${entity.className?upper_case}_ID);
</#list>
	}

	/**
	 * This must be set from outside, it's recommended to do this inside your Application object.
	 * Subject to change (static isn't nice).
	 */
	public static DaoSession daoSession;
<#--
##########################################
########## onCreate ##############
##########################################
--> 
	@Override
	public boolean onCreate() {
		// if(daoSession == null) {
		// throw new IllegalStateException("DaoSession must be set before content provider is created");
		// }
		DaoLog.d("Content Provider started: " + CONTENT_URI);
		return true;
	}

	protected SQLiteDatabase getDatabase() {
		if(daoSession == null) {
			throw new IllegalStateException("DaoSession must be set during content provider is active");
		}
		return daoSession.getDatabase();
	}

<#--
##########################################
########## Insert ##############
##########################################
-->
	@Override
	public Uri insert(Uri uri, ContentValues values) {
		<#if contentProvider.isReadOnly()>
			throw new UnsupportedOperationException("This content provider is readonly");
		<#else>
		int uriType = sURIMatcher.match(uri);
		long id = 0;
		String path = "";
		switch (uriType) {
			case ${entity.className?upper_case}_DIR:
				id = getDatabase().insert(TABLENAME, null, values);
				path = BASE_PATH + "/" + id;
				break;
			default:
				throw new IllegalArgumentException("Unknown URI: " + uri);
		}
		getContext().getContentResolver().notifyChange(uri, null);
		return Uri.parse(path);
		</#if>
	}


	@Override
	public int bulkInsert(Uri uri, ContentValues[] values) {
		<#if contentProvider.isReadOnly()>
			throw new UnsupportedOperationException("This content provider is readonly");
		<#else>
		int uriType = sURIMatcher.match(uri);

		// Pick the correct database for this operation
		SQLiteDatabase db = getDatabase();

		if (ACTIVATE_ALL_LOGS) {
			Log.d(LOG_TAG, "bulkInsert: uri=" + uri + ", match is " + uriType);
		}

		int numberInserted = 0;
		SQLiteStatement insertStmt;

		db.beginTransaction();
		try {
			switch (uriType) {
			<#list contentProvider.entities as entity>
				case ${entity.classNameDao}.${entity.tableName?upper_case}_DIR:
					insertStmt = db.compileStatement(${entity.classNameDao}.getBulkInsertString());
					for (ContentValues value : values) {
						${entity.classNameDao}.bindValuesInBulkInsert(insertStmt, value);
						insertStmt.execute();
						insertStmt.clearBindings();
					}
					insertStmt.close();
					db.setTransactionSuccessful();

					numberInserted = values.length;

					if (ACTIVATE_ALL_LOGS) {
						Log.d(LOG_TAG, "bulkInsert: uri=" + uri + " | nb inserts : " + numberInserted);
					}
					break;
			</#list>

				default:
					throw new IllegalArgumentException("Unknown URI " + uri);
			}
		} finally {
			db.endTransaction();
		}
		if (numberInserted > 0) {
			// Notify with the base uri, not the new uri (nobody is watching a new
			// record)
			getContext().getContentResolver().notifyChange(uri, null);
		}
		return numberInserted;
	</#if>
	}


	<#--
##########################################
########## Delete ##############
##########################################
		-->
	@Override
	public int delete(Uri uri, String selection, String[] selectionArgs) {
		<#if contentProvider.isReadOnly()>
			throw new UnsupportedOperationException("This content provider is readonly");
		<#else>
			int uriType = sURIMatcher.match(uri);
		SQLiteDatabase db = getDatabase();
		int rowsDeleted = 0;
		String id;
		switch (uriType) {
			case ${entity.className?upper_case}_DIR:
				rowsDeleted = db.delete(TABLENAME, selection, selectionArgs);
				break;
			case ${entity.className?upper_case}_ID:
				id = uri.getLastPathSegment();
				if (TextUtils.isEmpty(selection)) {
					rowsDeleted = db.delete(TABLENAME, PK + "=" + id, null);
				} else {
					rowsDeleted = db.delete(TABLENAME, PK + "=" + id + " and "
							+ selection, selectionArgs);
				}
				break;
			default:
				throw new IllegalArgumentException("Unknown URI: " + uri);
		}
		getContext().getContentResolver().notifyChange(uri, null);
		return rowsDeleted;
		</#if>
	}

<#--
##########################################
########## Update ##############
##########################################
-->
	@Override
	public int update(Uri uri, ContentValues values, String selection,
			String[] selectionArgs) {
		<#if contentProvider.isReadOnly()>
			throw new UnsupportedOperationException("This content provider is readonly");
		<#else>
			int uriType = sURIMatcher.match(uri);
		SQLiteDatabase db = getDatabase();
		int rowsUpdated = 0;
		String id;
		switch (uriType) {
			case ${entity.className?upper_case}_DIR:
				rowsUpdated = db.update(TABLENAME, values, selection, selectionArgs);
				break;
			case ${entity.className?upper_case}_ID:
				id = uri.getLastPathSegment();
				if (TextUtils.isEmpty(selection)) {
					rowsUpdated = db.update(TABLENAME, values, PK + "=" + id, null);
				} else {
					rowsUpdated = db.update(TABLENAME, values, PK + "=" + id
							+ " and " + selection, selectionArgs);
				}
				break;
			default:
				throw new IllegalArgumentException("Unknown URI: " + uri);
		}
		getContext().getContentResolver().notifyChange(uri, null);
		return rowsUpdated;
		</#if>
	}
	<#--
##########################################
########## Query ##############
##########################################
		-->
	@Override
	public Cursor query(Uri uri, String[] projection, String selection,
			String[] selectionArgs, String sortOrder) {

		SQLiteQueryBuilder queryBuilder = new SQLiteQueryBuilder();
		int uriType = sURIMatcher.match(uri);
		switch (uriType) {
			case ${entity.className?upper_case}_DIR:
				queryBuilder.setTables(TABLENAME);
				break;
			case ${entity.className?upper_case}_ID:
				queryBuilder.setTables(TABLENAME);
				queryBuilder.appendWhere(PK + "="
						+ uri.getLastPathSegment());
				break;
			default:
				throw new IllegalArgumentException("Unknown URI: " + uri);
		}

		SQLiteDatabase db = getDatabase();
		Cursor cursor = queryBuilder.query(db, projection, selection,
				selectionArgs, null, null, sortOrder);
		cursor.setNotificationUri(getContext().getContentResolver(), uri);

		return cursor;
	}

	<#--
##########################################
########## GetType ##############
##########################################
		-->
	@Override
	public final String getType(Uri uri) {
		switch (sURIMatcher.match(uri)) {
			case ${entity.className?upper_case}_DIR:
				return CONTENT_TYPE;
			case ${entity.className?upper_case}_ID:
				return CONTENT_ITEM_TYPE;
			default :
				throw new IllegalArgumentException("Unsupported URI: " + uri);
		}
	}
}
