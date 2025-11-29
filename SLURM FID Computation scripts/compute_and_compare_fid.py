import os
import argparse
import torch
import numpy as np
import pickle
from stylegan3.dataset import ImageFolderDataset
from dnnlib.util import open_url
from utils.util import FolderDataset, set_seeds, get_activations, calculate_frechet_distance

def compute_stats(path, batch_size, device, max_samples=None):
    if path.endswith('zip'):
        dataset = ImageFolderDataset(path)
    elif os.path.isdir(path):
        dataset = FolderDataset(path)
    else:
        raise NotImplementedError(f"Unsupported input path: {path}")

    queue = torch.utils.data.DataLoader(
        dataset=dataset, batch_size=batch_size, pin_memory=True, num_workers=1
    )

    with open_url('https://api.ngc.nvidia.com/v2/models/nvidia/research/stylegan3/versions/1/files/metrics/inception-2015-12-05.pkl') as f:
        model = pickle.load(f).to(device)
        model.eval()

    activations = get_activations(queue, model, device=device, max_samples=max_samples)
    mu = np.mean(activations, axis=0)
    sigma = np.cov(activations, rowvar=False)
    return mu, sigma


def main(args):
    set_seeds(0, 0)
    device = 'cuda:0' if torch.cuda.is_available() else 'cpu'

    # Load reference stats
    ref = np.load(args.ref_stats)
    ref_mu = ref['mu']
    ref_sigma = ref['sigma']

    # Compute stats for comparison images
    mu, sigma = compute_stats(args.path, args.batch_size, device, args.max_samples)

    # Optionally save the computed stats
    if args.save_stats:
        if not args.save_path:
            raise ValueError("You must provide --save_path if --save_stats is set.")
        os.makedirs(os.path.dirname(args.save_path), exist_ok=True)
        np.savez(args.save_path, mu=mu, sigma=sigma)
        print(f"Computed stats saved to {args.save_path}")

    # Calculate and print FID
    fid = calculate_frechet_distance(ref_mu, ref_sigma, mu, sigma)
    print(f'FID: {fid:.4f}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--path', type=str, required=True, help="Path to image folder or zip file")
    parser.add_argument('--ref_stats', type=str, required=True, help="Path to .npz file with reference stats")
    parser.add_argument('--batch_size', type=int, default=128)
    parser.add_argument('--max_samples', type=int, default=None)
    parser.add_argument('--save_stats', action='store_true', help="Flag to save computed stats")
    parser.add_argument('--save_path', type=str, help="Where to save the computed stats if --save_stats is used")

    args = parser.parse_args()
    main(args)
