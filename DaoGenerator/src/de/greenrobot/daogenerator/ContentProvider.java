package de.greenrobot.daogenerator;

import java.util.ArrayList;
import java.util.List;

public class ContentProvider {
    private final List<Entity> entities = new ArrayList<Entity>();
    private String authority;
    private String basePath;
    private String className;
    private String javaPackage;
    private boolean readOnly;
    private Schema schema;

    public ContentProvider(Schema schema) {
        this.schema = schema;
    }

    public void addEntity(Entity entity) {
        if (entity == null) {
            throw new NullPointerException("entity is null");
        }
        entities.add(entity);
    }

    public String getAuthority() {
        return authority;
    }

    public void setAuthority(String authority) {
        this.authority = authority;
    }

    public String getBasePath() {
        return basePath;
    }

    public void setBasePath(String basePath) {
        this.basePath = basePath;
    }

    public String getClassName() {
        return className;
    }

    public void setClassName(String className) {
        this.className = className;
    }

    public String getJavaPackage() {
        return javaPackage;
    }

    public void setJavaPackage(String javaPackage) {
        this.javaPackage = javaPackage;
    }

    public boolean isReadOnly() {
        return readOnly;
    }

    public void readOnly() {
        this.readOnly = true;
    }

    public List<Entity> getEntities() {
        return entities;
    }

    public void init2ndPass() {
        if (authority == null) {
            authority = schema.getDefaultJavaPackage() + ".provider";
        }
        if (basePath == null) {
            basePath = "";
        }
        if (className == null) {
            className = "EntityContentProvider";
        }
        if (javaPackage == null) {
            javaPackage = schema.getDefaultJavaPackage();
        }

    }

}
