for class_dir in */ ; do
    if [ -d "$class_dir/images" ]; then
        mv "$class_dir/images/"* "$class_dir/"
        rmdir "$class_dir/images"
    fi
done
