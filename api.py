from flask import Flask, request, jsonify
import tensorflow as tf
import cv2
import numpy as np
import os
import shutil
import firebase_admin
from firebase_admin import credentials
from firebase_admin import storage

app = Flask(__name__)

# Initialize Firebase credentials
cred = credentials.Certificate("C:\\Users\\Administrator\\Desktop\\Flask\\email-auth-54516-firebase-adminsdk-ebvb8-dcd7c05b35.json")  # Replace with your own service account key path
firebase_admin.initialize_app(cred, {'storageBucket': 'email-auth-54516.appspot.com'})

model = tf.keras.models.load_model('EFF_V2M_299-50+20')

label_list = ['Normal', 'Abnormal']


def process_video(file):
    file_path = os.path.join('tmp', file.filename)
    file.save(file_path)

    # Create a directory to store the frames
    frames_dir = os.path.join('tmp', 'frames')
    os.makedirs(frames_dir, exist_ok=True)

    # Open the video file
    video = cv2.VideoCapture(file_path)

    frame_count = 0  # Initialize frame_count as 0
    while True:
        # Read a frame from the video
        ret, frame = video.read()
        if not ret:
            break

        # Resize and save the frame as an image
        frame = cv2.resize(frame, (299, 299))
        frame_count += 1  # Increment frame_count
        frame_path = os.path.join(frames_dir, f"frame_{frame_count}.jpg")
        cv2.imwrite(frame_path, frame)

    # Release the video file and remove it
    video.release()
    os.remove(file_path)

    return frames_dir, frame_count


def predict_image(frame_path):
    img = cv2.imread(frame_path)
    img = cv2.resize(img, (299, 299))
    img = img.reshape(1, 299, 299, 3)
    pl = np.argmax(model.predict(img), axis=-1)
    label = label_list[pl[0]]
    frame_number = int(os.path.basename(frame_path).split('_')[1].split('.')[0])
    frame_name = f"Frame-{frame_number}"
    return label, frame_name


def create_video(frames_dir, frame_count, fps=5):
    # Get the first frame to extract dimensions
    frame_path = os.path.join(frames_dir, "frame_1.jpg")
    frame = cv2.imread(frame_path)
    height, width, _ = frame.shape

    # Define the output video file path
    output_path = os.path.join('tmp', 'output1.mp4')

    # Initialize the VideoWriter object with specified FPS
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    video_writer = cv2.VideoWriter(output_path, fourcc, fps, (width, height))

    # Write each frame to the video
    for i in range(1, frame_count + 1):
        frame_path = os.path.join(frames_dir, f"frame_{i}.jpg")
        frame = cv2.imread(frame_path)
        video_writer.write(frame)

    # Release the video writer
    video_writer.release()

    return output_path


def func(file):
    file_path = os.path.join('tmp', file.filename)
    file.save(file_path)
    img = cv2.imread(file_path)
    img = cv2.resize(img, (299, 299))
    img = img.reshape(1, 299, 299, 3)
    pl = np.argmax(model.predict(img), axis=-1)
    os.remove(file_path)
    return label_list[pl[0]]


def upload_video_to_firebase(video_path, destination_path):
    try:
        # Create a storage client
        bucket = storage.bucket()

        # Specify the path and filename for the video in the bucket
        blob = bucket.blob(destination_path)

        # Upload the video file
        blob.upload_from_filename(video_path)

        print('Video uploaded to Firebase Storage successfully.')
    except Exception as e:
        print('Error uploading video to Firebase Storage:', str(e))


@app.route('/ipredict', methods=['POST'])
def ipredict():
    if 'image' not in request.files:
        return 'No file provided', 400

    image_file = request.files['image']
    if not image_file.filename.lower().endswith('.jpg'):
        return 'Invalid file type, must be .jpg', 400

    prediction = func(image_file)
    print(prediction)
    return prediction


@app.route('/vpredict', methods=['POST'])
def vpredict():
    if 'video' not in request.files:
        return 'No file provided', 400

    video_file = request.files['video']
    if not video_file.filename.lower().endswith('.mp4'):
        return 'Invalid file type, must be .mp4', 400

    frames_dir, frame_count = process_video(video_file)

    predictions = []
    normal_count = 0
    normal_frames = []
    abnormal_count = 0
    abnormal_frames = []

    for i in range(1, frame_count + 1):
        frame_path = os.path.join(frames_dir, f"frame_{i}.jpg")
        prediction, frame_name = predict_image(frame_path)
        predictions.append(prediction)
        print(f"Frame {i}: {prediction}")

        frame_number = frame_name.split('-')[1]
        frame_name = f"Frame-{frame_number}"

        if prediction == 'Abnormal':
            aggregated_result = 'Abnormal'
            abnormal_count += 1
            abnormal_frames.append(frame_name)
        else:
            normal_count += 1
            normal_frames.append(frame_name)

    video_path = create_video(frames_dir, frame_count, fps=5)
    shutil.rmtree(frames_dir)  # Remove the frames directory

    if 'aggregated_result' not in locals():
        aggregated_result = 'Normal'

    print("Aggregated Result:", aggregated_result)

    # Upload the video to Firebase Storage
    destination_path = 'videos/output1.mp4'  # Specify the desired path and filename in the storage bucket
    upload_video_to_firebase(video_path, destination_path)

    return jsonify({
        'total_frames': frame_count,
        'normal_count': normal_count,
        'normal_frames': normal_frames,
        'abnormal_count': abnormal_count,
        'abnormal_frames': abnormal_frames,
        'video_path': destination_path  # Return the Firebase Storage path of the uploaded video
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
