# zlog 源码 学习 note

## winzlog 好像只认 buf_min 不会扩充

```c
// 注册 output 函数
zlog_rule_t *zlog_rule_new(char *line,
    zc_arraylist_t *levels,
    zlog_format_t * default_format,
    zc_arraylist_t * formats,
    unsigned int file_perms,
    size_t fsync_period,
    int * time_cache_count)
{
    /* try to figure out if the log file path is dynamic or static */
    if (a_rule->dynamic_specs) {
        if (a_rule->archive_max_size <= 0) {
            a_rule->output = zlog_rule_output_dynamic_file_single;
        } else {
            a_rule->output = zlog_rule_output_dynamic_file_rotate;
        }
    }

    ...

    if (a_rule->archive_max_size <= 0) {
        a_rule->output = zlog_rule_output_static_file_single;
    } else {
        /* as rotate, so need to reopen everytime */
        a_rule->output = zlog_rule_output_static_file_rotate;
    }

}

// output 函数定义
static int zlog_rule_output_dynamic_file_single(zlog_rule_t * a_rule, zlog_thread_t * a_thread)
{
    int fd;

    zlog_rule_gen_path(a_rule, a_thread);

    if (zlog_format_gen_msg(a_rule->format, a_thread)) {
        zc_error("zlog_format_output fail");
        return -1;
    }
    ...
}

int zlog_format_gen_msg(zlog_format_t * a_format, zlog_thread_t * a_thread)
{
    int i;
    zlog_spec_t *a_spec;

    zlog_buf_restart(a_thread->msg_buf);

    zc_arraylist_foreach(a_format->pattern_specs, i, a_spec) {
        if (zlog_spec_gen_msg(a_spec, a_thread) == 0) {
            continue;
        } else {
            return -1;
        }
    }

    return 0;
}

#define zlog_spec_gen_msg(a_spec, a_thread) \
    a_spec->gen_msg(a_spec, a_thread)

// 注册 gen_msg 注册 write_buf
zlog_spec_t *zlog_spec_new(char *pattern_start, char **pattern_next, int *time_cache_count)
{
    ...
    a_spec->gen_msg = zlog_spec_gen_msg_reformat;
    ...
    a_spec->gen_msg = zlog_spec_gen_msg_direct;
    ...
    a_spec->write_buf = zlog_spec_write_str;
    a_spec->write_buf = zlog_spec_write_time;
    a_spec->write_buf = zlog_spec_write_mdc;
    a_spec->write_buf = zlog_spec_write_ms;
    a_spec->write_buf = zlog_spec_write_us;
    a_spec->write_buf = zlog_spec_write_category;
    a_spec->write_buf = zlog_spec_write_srcfile;
    a_spec->write_buf = zlog_spec_write_srcfile_neat;
    a_spec->write_buf = zlog_spec_write_hostname;
    a_spec->write_buf = zlog_spec_write_srcline;
    a_spec->write_buf = zlog_spec_write_usrmsg;
    a_spec->write_buf = zlog_spec_write_newline;
    a_spec->write_buf = zlog_spec_write_pid;
    a_spec->write_buf = zlog_spec_write_srcfunc;
    a_spec->write_buf = zlog_spec_write_level_lowercase;
    a_spec->write_buf = zlog_spec_write_level_uppercase;
    a_spec->write_buf = zlog_spec_write_tid_hex;
    a_spec->write_buf = zlog_spec_write_tid_long;
    a_spec->write_buf = zlog_spec_write_percent;
    a_spec->write_buf = zlog_spec_write_str;
    ...
}

// gen_msg 函数定义
static int zlog_spec_gen_msg_reformat(zlog_spec_t * a_spec, zlog_thread_t * a_thread)
{
    int rc;

    zlog_buf_restart(a_thread->pre_msg_buf);

    rc = a_spec->write_buf(a_spec, a_thread, a_thread->pre_msg_buf);
    if (rc < 0) {
        zc_error("a_spec->gen_buf fail");
        return -1;
    } else if (rc > 0) {
        /* buf is full, try printf */
    }

    return zlog_buf_adjust_append(a_thread->msg_buf,
        zlog_buf_str(a_thread->pre_msg_buf), zlog_buf_len(a_thread->pre_msg_buf),
        a_spec->left_adjust, a_spec->min_width, a_spec->max_width);
}

static int zlog_spec_write_str(zlog_spec_t * a_spec, zlog_thread_t * a_thread, zlog_buf_t * a_buf)
{
    return zlog_buf_append(a_buf, a_spec->str, a_spec->len);
}


int zlog_buf_append(zlog_buf_t * a_buf, const char *str, size_t str_len)
{
    ...
    rc = zlog_buf_resize(a_buf, str_len - (a_buf->end - a_buf->tail));
    ...
    memcpy(a_buf->tail, str, str_len);
    ...
    return 0;
}
```

## zlog 设计

```C
static int zlog_init_inner(const char *confpath)
{
    int rc = 0;

    /* the 1st time in the whole process do init */
    if (zlog_env_init_version == 0) {
        /* clean up is done by OS when a thread call pthread_exit */
        rc = pthread_key_create(&zlog_thread_key, (void (*) (void *)) zlog_thread_del);
        if (rc) {
            zc_error("pthread_key_create fail, rc[%d]", rc);
            goto err;
        }

        /* if some thread do not call pthread_exit, like main thread
            * atexit will clean it 
            */
        rc = atexit(zlog_clean_rest_thread);
        if (rc) {
            zc_error("atexit fail, rc[%d]", rc);
            goto err;
        }
        zlog_env_init_version++;
    } /* else maybe after zlog_fini() and need not create pthread_key */

    zlog_env_conf = zlog_conf_new(confpath);
    if (!zlog_env_conf) {
        zc_error("zlog_conf_new[%s] fail", confpath);
        goto err;
    }

    zlog_env_categories = zlog_category_table_new();
    if (!zlog_env_categories) {
        zc_error("zlog_category_table_new fail");
        goto err;
    }

    zlog_env_records = zlog_record_table_new();
    if (!zlog_env_records) {
        zc_error("zlog_record_table_new fail");
        goto err;
    }

    return 0;
    err:
    zlog_fini_inner();
    return -1;
}
```