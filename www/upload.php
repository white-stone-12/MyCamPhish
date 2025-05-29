<?php
$dir = __DIR__ . '/../captured';
if (!file_exists($dir)) {
    mkdir($dir, 0755, true);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['webcam'])) {
    $filename = $dir . '/' . uniqid('img_', true) . '.jpg';
    if (move_uploaded_file($_FILES['webcam']['tmp_name'], $filename)) {
        http_response_code(200);
        echo "Image saved.";
    } else {
        http_response_code(500);
        echo "Error saving image.";
    }
} else {
    http_response_code(400);
    echo "No image received.";
}
?>
