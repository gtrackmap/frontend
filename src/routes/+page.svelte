<script lang="ts">
  import Icon from '$lib/components/Icon.svelte';

	let form: HTMLFormElement;
	let apiUrl = '/api';
  let advanced = false;
  let processing = false;

	const buildQuery = async () => {
		const data = new FormData(form);
		data.delete('style');
		data.delete('typ');
		const response = await fetch(`${apiUrl}/build-overpass-query`, { method: 'POST', body: data });
		if (!response.ok) {
			throw new Error('Failed to build query');
		}

		return await response.text();
	};

	const fetchOsmData = async (query: string) => {
		const data = new URLSearchParams();
		data.append('data', query);

		const response = await fetch('https://overpass-api.de/api/interpreter', {
			method: 'POST',
			body: data,
			headers: {
				'Content-Type': 'application/x-www-form-urlencoded'
			}
		});

		if (!response.ok) {
			throw new Error('Failed to fetch OSM data');
		}

		return await response.blob();
	};

	const buildMap = async (osmData: Blob) => {
		const data = new FormData(form);

		data.append('osm-data', osmData);
		data.delete('tracks');
		data.delete('radius');

		const response = await fetch(`${apiUrl}/build-map`, { method: 'POST', body: data });
		return await response.blob();
	};

	const downloadFile = (blob: Blob) => {
		const href = URL.createObjectURL(blob);
		const a = Object.assign(document.createElement('a'), {
			href,
			style: 'display:none',
			download: 'map.zip'
		});

		document.body.appendChild(a);
		a.click();
		URL.revokeObjectURL(href);
		a.remove();
	};

	const handleSubmit = async (event: Event) => {
		event.preventDefault();
    processing = true;

		const query = await buildQuery();
		const osmData = await fetchOsmData(query);
		const mapData = await buildMap(osmData);
		downloadFile(mapData);
    processing = false;
	};
</script>

<div class="max-w-sm mx-auto mt-4">
  <h1 class="text-4xl mb-8 text-center flex items-center gap-2"><Icon id="map"/>Trackmap</h1>

  <form on:submit={handleSubmit} bind:this={form} class="flex flex-col gap-4">
    <label class="flex flex-col gap-2">
      <span class="font-semibold">Tracks</span>
      <input type="file" name="tracks" accept=".gpx" multiple required/>
    </label>

    <label class="flex flex-col gap-2">
      <span class="font-semibold">Radius (m)</span>
      <input type="number" name="radius" value={1000} class="p-3 border" required/>
    </label>

    {#if advanced}
      <label class="flex flex-col gap-2">
        <span class="font-semibold">Style</span>
        <input type="file" name="style" accept=".zip" />
      </label>

      <label class="flex flex-col gap-2">
        <span class="font-semibold">Typ</span>
        <input type="file" name="typ" accept=".txt" />
      </label>
    {:else}
      <button on:click={() => advanced = true}>Advanced options</button>
    {/if}

    <button class="bg-green-400 disabled:bg-green-300 text-white font-bold p-3 flex justify-center" type="submit" disabled={processing}>
      {#if processing}
        <Icon id="loader" class="text-white animate-spin text-xl"/>
      {:else}
        Generate Map
      {/if}
    </button>
  </form>
</div>
