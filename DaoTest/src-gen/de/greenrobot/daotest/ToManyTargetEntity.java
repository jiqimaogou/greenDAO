package de.greenrobot.daotest;

// THIS CODE IS GENERATED BY greenDAO, DO NOT EDIT. Enable "keep" sections if you want to edit. 
/**
 * Entity mapped to table TO_MANY_TARGET_ENTITY (schema version 1).
 */
public class ToManyTargetEntity {

    private Long toManyId;
    private Long id;

    public ToManyTargetEntity() {
    }

    public ToManyTargetEntity(Long id) {
        this.id = id;
    }

    public ToManyTargetEntity(Long toManyId, Long id) {
        this.toManyId = toManyId;
        this.id = id;
    }

    public Long getToManyId() {
        return toManyId;
    }

    public void setToManyId(Long toManyId) {
        this.toManyId = toManyId;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

}